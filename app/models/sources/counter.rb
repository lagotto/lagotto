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

  # Format Counter events for all articles as csv
  # Show historical data if options[:format] is used
  # options[:format] can be "html", "pdf" or "combined"
  # options[:month] and options[:year] are the starting month and year, default to last month
  def self.to_csv(options = {})

    if ["html","pdf","xml","combined"].include? options[:format]
      view = "counter_#{options[:format]}_views"
    else
      view = "counter"
    end

    service_url = "#{CONFIG[:couchdb_url]}_design/reports/_view/#{view}"

    result = get_json(service_url, options)
    return nil if result.blank?

    result = result["rows"]

    if view == "counter"
      CSV.generate do |csv|
        csv << ["doi", "html", "pdf", "total"]
        result.each { |row| csv << [row["key"], row["value"]["html"], row["value"]["pdf"], row["value"]["total"]] }
      end
    else
      dates = self.date_range(options).map { |date| "#{date[:year]}-#{date[:month]}" }

      CSV.generate do |csv|
        csv << ["doi"] + dates
        result.each { |row| csv << [row["key"]] + dates.map { |date| row["value"][date] || 0 }}
      end
    end
  end

  # Array of hashes in format [{ month: 12, year: 2013 },{ month: 1, year: 2014 }]
  # Provide starting month and year as input, otherwise defaults to this month
  def self.date_range(options = {})
    end_date = Date.today

    if options[:month] && options[:year]
      start_date = Date.new(options[:year].to_i, options[:month].to_i, 1) rescue end_date
      start_date = end_date if start_date > end_date
    else
      start_date = end_date
    end

    dates = (start_date..end_date).map { |date| { month: date.month, year: date.year } }.uniq
  end

  def get_data(article, options={})

    # Check that article has DOI
    return { :events => [], :event_count => nil } if article.doi.blank?

    query_url = get_query_url(article)
    result = get_xml(query_url, options)

    return nil if result.nil?

    views = []
    event_count = 0
    result.xpath("//rest/response/results/item").each do | view |

      month = view.at_xpath("month")
      year = view.at_xpath("year")
      month = view.at_xpath("month")
      html = view.at_xpath("get-document")
      xml = view.at_xpath("get-xml")
      pdf = view.at_xpath("get-pdf")

      curMonth = {}
      curMonth[:month] = month.content
      curMonth[:year] = year.content

      if pdf
        curMonth[:pdf_views] = pdf.content
        event_count += pdf.content.to_i
      else
        curMonth[:pdf_views] = 0
      end

      if xml
        curMonth[:xml_views] = xml.content
        event_count += xml.content.to_i
      else
        curMonth[:xml_views] = 0
      end

      if html
        curMonth[:html_views] = html.content
        event_count += html.content.to_i
      else
        curMonth[:html_views] = 0
      end

      views << curMonth
    end

    event_metrics = { :pdf => views.nil? ? nil : views.inject(0) { |sum, hash| sum + hash[:pdf_views].to_i },
                      :html => views.nil? ? nil : views.inject(0) { |sum, hash| sum + hash[:html_views].to_i },
                      :shares => nil,
                      :groups => nil,
                      :comments => nil,
                      :likes => nil,
                      :citations => nil,
                      :total => event_count }

    {:events => views,
     :events_url => query_url,
     :event_count => event_count,
     :event_metrics => event_metrics,
     :attachment => views.empty? ? nil : {:filename => "events.xml", :content_type => "text\/xml", :data => result.to_s }}

  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end
end