# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Import
  # include HTTP request helpers
  include Networkable

  TYPES_WITH_TITLE = %w(journal-article proceedings-article dissertation standard report book monograph edited-book reference-book dataset)

  attr_accessor :filter, :sample, :rows

  def initialize(options = {})
    from_update_date = options.fetch(:from_update_date, nil)
    until_update_date = options.fetch(:until_update_date, nil)
    from_pub_date = options.fetch(:from_pub_date, nil)
    until_pub_date = options.fetch(:until_pub_date, nil)
    type = options.fetch(:type, nil)
    member = options.fetch(:member, nil)
    issn = options.fetch(:issn, nil)
    sample = options.fetch(:sample, 0)

    @file = options.fetch(:file, nil)
    @sample = sample.to_i

    unless @file
      from_update_date = Date.yesterday.to_s(:db) if from_update_date.blank?
      until_update_date= Date.yesterday.to_s(:db) if until_update_date.blank?
      until_pub_date= Date.today.to_s(:db) if until_pub_date.blank?

      @filter = "from-update-date:#{from_update_date}"
      @filter += ",until-update-date:#{until_update_date}"
      @filter += ",until-pub-date:#{until_pub_date}"
      @filter += ",from-pub-date:#{from_pub_date}" if from_pub_date
      @filter += ",type:#{type}" if type
      @filter += ",member:#{member}" if member
      @filter += ",issn:#{issn}" if issn
    end
  end

  def total_results(options={})
    if @file
      @file.length
    else
      result = get_result(query_url(offset = 0, rows = 0), options)

      # extend hash fetch method to nested hashes
      result.extend Hashie::Extensions::DeepFetch
      result.deep_fetch('message', 'total-results') { 0 }
    end
  end

  def queue_article_import
    if @sample > 0
      delay(priority: 0, queue: "article-import-queue").process_data
    else
      (0...total_results).step(1000) do |offset|
        delay(priority: 0, queue: "article-import-queue").process_data(offset)
      end
    end
    delay(priority: 0, queue: "article-cache-queue").expire_cache
  end

  def process_data(offset = 0)
    result = get_data(offset)
    result = parse_data(result)
    result = import_data(result)
    result.length
  end

  def query_url(offset = 0, rows = 1000)
    url = "http://api.crossref.org/works?"
    if @sample > 0
      params = { filter: @filter, sample: @sample }
    else
      params = { filter: @filter, offset: offset, rows: rows }
    end
    url + params.to_query
  end

  def get_data(offset = 0, options={})
    if @file
      result = get_text(offset)
    else
      result = get_result(query_url(offset), options)
    end

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def get_text(offset = 0, rows = 1000)
    text = @file.slice(offset...(offset + rows))
    items = text.map do |line|
      line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
      raw_uid, raw_published_on, raw_title = line.strip.split(" ", 3)

      uid = Article.from_uri(raw_uid.strip).values.first
      if raw_published_on
        # date_parts is an array of non-null integers in the form [year, month, day]
        # everything else should be nil and thrown away with compact
        date_parts = raw_published_on.split("-")
        date_parts = date_parts.map { |x| x.to_i > 0 ? x.to_i : nil }.compact
      else
        date_parts = []
      end
      title = raw_title ? raw_title.strip.chomp('.') : ""

      { Article.uid => uid,
        "issued" => { "date-parts" => [date_parts] },
        "title" => [title],
        "type" => "standard" }
    end

    { "status" => "ok",
      "message" => { "items" => items } }
  end

  def parse_data(result)
    # return early if an error occured
    return result if result["status"] != "ok"

    items = result['message'] && result.deep_fetch('message', 'items') { nil }
    Array(items).map do |item|
      uid = item["DOI"] || item[Article.uid]
      date_parts = item["issued"]["date-parts"][0]
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      if TYPES_WITH_TITLE.include?(item["type"])
        title = item["title"][0]
      else
        title = item["title"][0].presence || item["container-title"][0].presence || "No title"
      end

      { Article.uid_as_sym => uid,
        title: title,
        year: year,
        month: month,
        day: day }
    end
  end

  def import_data(items)
    Array(items).map do |item|
      article = Article.find_or_create(item)
      article ? article.id : nil
    end
  end

  def expire_cache
    if ActionController::Base.perform_caching
      Rails.cache.write('status:timestamp', Time.zone.now.utc.iso8601)
      status_url = "http://#{CONFIG[:server_name]}/api/v5/status?api_key=#{CONFIG[:api_key]}"
      get_result(status_url, timeout: 300)
    end
  end
end
