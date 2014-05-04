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

class Copernicus < Source
  def get_query_url(article)
    return nil unless article.doi =~ /^10.5194/

    url % { :doi => article.doi }
  end

  def request_options
    { username: username, password: password }
  end

  def parse_data(result, article, options={})
    return result if result[:error]

    events = result.fetch('counter') { {} }

    pdf = events.fetch('PdfDownloads') { 0 }
    html = events.fetch('AbstractViews') { 0 }
    total = events.values.reduce(0) { |sum, x| x.nil? ? sum : sum + x }

    events = result['data'] ? {} : result

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(pdf: pdf, html: html, total: total) }
  end

  def config_fields
    [:url, :username, :password]
  end
end
