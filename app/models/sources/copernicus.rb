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
    if article.doi =~ /^10.5194/
      url % { :doi => article.doi }
    else
      nil
    end
  end

  def request_options
    { username: username, password: password }
  end

  def parse_data(result, options={})
    return { events: [], event_count: nil } if result.empty? || !result["counter"]

    if result["counter"].values.all? { |x| x.nil? }
      event_count = 0
      pdf = 0
      html = 0
    else
      event_count = result["counter"].values.reduce(0) { |sum, x| sum + (x ? x : 0) }
      pdf = result["counter"]["PdfDownloads"]
      html = result["counter"]["AbstractViews"]
    end

    { events: result,
      events_url: nil,
      event_count: event_count,
      event_metrics: get_event_metrics(pdf: pdf, html: html, total: event_count) }
  end

  protected

  def config_fields
    [:url, :username, :password]
  end
end
