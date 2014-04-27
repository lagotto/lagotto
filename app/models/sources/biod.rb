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

    events = Array(result.deep_fetch('rest', 'response', 'results', 'item') { [] }).map do |item|
      { month: item['month'],
        year: item['year'],
        pdf_views: item['get_pdf'] || 0,
        xml_views: item['get_xml'] || 0,
        html_views: item['get_document'] || 0 }
    end

    pdf = events.reduce(0) { |sum, hash| sum + hash[:pdf_views].to_i }
    html = events.reduce(0) { |sum, hash| sum + hash[:html_views].to_i }
    xml = events.reduce(0) { |sum, hash| sum + hash[:xml_views].to_i }
    total = pdf + html + xml

    { :events => events,
      :event_count => total,
      :event_metrics => get_event_metrics(pdf: pdf, html: html, total: total) }
  end

  def request_options
    { content_type: 'xml' }
  end

  def get_config_fields
    [{ :field_name => "url", :field_type => "text_area", :size => "90x2" }]
  end

  def obsolete?
    true
  end
end
