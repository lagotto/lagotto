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

  DOI_TYPES = %w{ journal-article, proceedings-article, dissertation, standard, report, book, monograph, edited-book, reference-book, dataset }

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

    @sample = sample.to_i
  end

  def total_results(options={})
    result = get_result(query_url(offset = 0, rows = 0), options)

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
    result.deep_fetch('message', 'total-results') { 0 }
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
    result = get_result(query_url(offset), options)

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result)
    # return early if an error occured
    return result if result["status"] != "ok"

    items = result['message'] && result.deep_fetch('message', 'items') { nil }
    Array(items).map do |item|
      date_parts = item["issued"]["date-parts"][0]
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      if DOI_TYPES.include?(item["type"])
        title = item["title"][0]
      else
        title = item["title"][0].presence || item["container-title"][0].presence || "No title"
      end

      { doi: item["DOI"],
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
    Rails.cache.write('status:timestamp', Time.zone.now.utc.iso8601)
    status_url = "http://#{CONFIG[:hostname]}/api/v5/status?api_key=#{CONFIG[:api_key]}"
    get_result(status_url, timeout: 300)
  end
end
