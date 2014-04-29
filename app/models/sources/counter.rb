# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
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

class Counter < Source
  # include date methods concern
  include Dateable

  def get_query_url(article)
    if article.doi =~ /^10.1371/
      url % { :doi => article.doi_escaped }
    else
      nil
    end
  end

  def request_options
    { content_type: "xml"}
  end

  def parse_data(result, article, options={})
    events = get_events(result)

    pdf = get_sum(events, :pdf_views)
    html = get_sum(events, :html_views)
    xml = get_sum(events, :xml_views)
    total = pdf + html + xml

    { events: events,
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(pdf: pdf, html: html, total: total) }
  end

  # Format Counter events for all articles as csv
  # Show historical data if options[:format] is used
  # options[:format] can be "html", "pdf" or "combined"
  # options[:month] and options[:year] are the starting month and year, default to last month
  def to_csv(options = {})
    if ["html", "pdf", "xml", "combined"].include? options[:format]
      view = "counter_#{options[:format]}_views"
    else
      view = "counter"
    end

    service_url = "#{CONFIG[:couchdb_url]}_design/reports/_view/#{view}"

    result = get_result(service_url, options)
    return nil if result.blank? || result["rows"].blank?

    if view == "counter"
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

  def get_events(result)
    Array(result.deep_fetch('rest', 'response', 'results', 'item') { [] }).map do |item|
      { month: item['month'],
        year: item['year'],
        pdf_views: item['get_pdf'] || 0,
        xml_views: item['get_xml'] || 0,
        html_views: item['get_document'] || 0 }
    end
  end

  def config_fields
    [:url]
  end

  def cron_line
    config.cron_line || "* 4 * * *"
  end
end
