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

class Biod < Source
  def parse_data(article, options={})
    result = get_data(article, options)

    return result if result.nil? || result == { events: [], event_count: nil }

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

    pdf = views.nil? ? nil : views.reduce(0) { |sum, hash| sum + hash["pdf_views"].to_i }
    html =  views.nil? ? nil : views.reduce(0) { |sum, hash| sum + hash["html_views"].to_i }

    {:events => views,
     :events_url => query_url,
     :event_count => event_count,
     :event_metrics => get_event_metrics(pdf: pdf, html: html, total: event_count),
     :attachment => views.empty? ? nil : {:filename => "events.xml", :content_type => "text\/xml", :data => result.to_s }}
  end

  def request_options
    { content_type: 'xml' }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def obsolete?
    true
  end
end
