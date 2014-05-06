# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2013 by Public Library of Science, a non-profit corporation
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

class Pmc < Source
  # include date methods concern
  include Dateable

  def parse_data(result, article, options={})
    return result if result[:error]

    events = Array(result["views"])

    pdf = get_sum(events, 'pdf')
    html = get_sum(events, 'full-text')
    total = pdf + html

    { events: events,
      events_by_day: [],
      events_by_month: get_events_by_month(events),
      events_url: get_events_url(article),
      event_count: total,
      event_metrics: get_event_metrics(pdf: pdf, html: html, total: total) }
  end

  def get_events_by_month(events)
    events.map do |event|
      { month: event['month'].to_i,
        year: event['year'].to_i,
        html: event['full-text'].to_i,
        pdf: event['pdf'].to_i }
    end
  end

  # Retrieve usage stats in XML and store in /data directory. Returns an empty array if no error occured
  def get_feed(month, year, options={})
    options[:source_id] = id

    journals_array = journals.split(" ")
    journals_with_errors = []
    journals_array.each do |journal|
      feed_url = get_feed_url(month, year, journal)
      filename = "pmcstat_#{journal}_#{month}_#{year}.xml"

      if save_to_file(feed_url, filename, options).nil?
        Alert.create(:exception => "",
                     :class_name => "Net::HTTPInternalServerError",
                     :message => "PMC Usage stats for journal #{journal}, month #{month}, year #{year} could not be saved",
                     :status => 500,
                     :source_id => id)
        journals_with_errors << journal
      end
    end
    journals_with_errors
  end

  # Parse usage stats and store in CouchDB. Returns an empty array if no error occured
  def parse_feed(month, year, options={})
    journals_array = journals.split(" ")
    journals_with_errors = []
    journals_array.each do |journal|
      filename = "pmcstat_#{journal}_#{month}_#{year}.xml"
      file = File.open("#{Rails.root}/data/#{filename}", 'r') { |f| f.read }
      document = Nokogiri::XML(file)

      status = document.at_xpath("//pmc-web-stat/response/@status").value
      if status != "0"
        error_message = document.at_xpath("//pmc-web-stat/response/error").content
        Alert.create(:exception => "", :class_name => "Net::HTTPInternalServerError",
                     :message => "PMC Usage stats for journal #{journal}, month #{month} and year #{year}: #{error_message}",
                     :status => 500,
                     :source_id => id)
        journals_with_errors << journal
      else
        # go through all the articles in the xml document
        document.xpath("//article").each do |article|
          article = article.to_hash
          article = article["article"]

          doi = article["meta-data"]["doi"]
          # sometimes doi metadata are missing
          break unless doi

          view = article["usage"]
          view['year'] = year.to_s
          view['month'] = month.to_s

          # try to get the existing information about the given article
          data = get_result(db_url + CGI.escape(doi))

          if data['views'].nil?
            data = { 'views' => [view] }
          else
            # update existing entry
            data['views'].delete_if { |view| view['month'] == month.to_s && view['year'] == year.to_s }
            data['views'] << view
          end

          put_alm_data(db_url + CGI.escape(doi), data: data)
        end
      end
    end
    journals_with_errors
  end

  def put_database
    put_alm_data(db_url)
  end

  def get_feed_url(month, year, journal)
    feed_url % { year: year, month: month, journal: journal, username: username, password: password }
  end

  def get_events_url(article)
    if article.pmcid.present?
      events_url % { :pmcid => article.pmcid }
    else
      nil
    end
  end

  # Format Pmc events for all articles as csv
  # Show historical data if options[:format] is used
  # options[:format] can be "html", "pdf" or "combined"
  # options[:month] and options[:year] are the starting month and year, default to last month
  def to_csv(options = {})
    if ["html", "pdf", "combined"].include? options[:format]
      view = "pmc_#{options[:format]}_views"
    else
      view = "pmc"
    end

    service_url = "#{CONFIG[:couchdb_url]}_design/reports/_view/#{view}"

    result = get_result(service_url, options)
    return nil if result.blank? || result["rows"].blank?

    if view == "pmc"
      CSV.generate do |csv|
        csv << [CONFIG[:uid], "html", "pdf", "total"]
        result["rows"].each { |row| csv << [row["key"], row["value"]["html"], row["value"]["pdf"], row["value"]["total"]] }
      end
    else
      dates = date_range(options).map { |date| "#{date[:year]}-#{date[:month]}" }

      CSV.generate do |csv|
        csv << [CONFIG[:uid]] + dates
        result["rows"].each { |row| csv << [row["key"]] + dates.map { |date| row["value"][date] || 0 } }
      end
    end
  end

  def url
    db_url + "%{doi}"
  end

  def config_fields
    [:db_url, :feed_url, :events_url, :journals, :username, :password]
  end

  def feed_url
    config.feed_url || "http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=%{year}&month=%{month}&jrid=%{journal}&user=%{username}&password=%{password}"
  end

  def events_url
    config.events_url  || "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC%{pmcid}"
  end

  def journals
    config.journals
  end

  def journals=(value)
    config.journals = value
  end

  def cron_line
    config.cron_line || "0 5 9 * *"
  end
end
