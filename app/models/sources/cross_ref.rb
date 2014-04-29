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

class CrossRef < Source
  validates :url, :password, presence: true, if: "CONFIG[:doi_prefix]"

  def get_query_url(article)
    if article.doi.blank? || Time.zone.now - article.published_on.to_time < 1.day
      nil
    elsif article.is_publisher?
      url % { :username => username, :password => password, :doi => article.doi_escaped }
    else
      pid = password.blank? ? username : username + ":" + password
      openurl % { :pid => pid, :doi => article.doi_escaped }
    end
  end

  def request_options
    { content_type: 'xml' }
  end

  def parse_data(result, article, options={})
    events = get_events(result)

    if article.is_publisher?
      event_count = events.length
    else
      event_count = result.deep_fetch('crossref_result', 'query_result', 'body', 'query', 'fl_count') { 0 }
    end

    { events: events,
      events_url: nil,
      event_count: event_count.to_i,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def get_events(result)
    if result['crossref_result']['query_result']['body']['forward_link'].is_a?(Array)
      result['crossref_result']['query_result']['body']['forward_link'].map do |item|
        { :event => item['journal_cite'], :event_url => Article.to_url(item['journal_cite']['doi']) }
      end
    else
      []
    end
  end

  def config_fields
    [:url, :openurl, :username, :password]
  end

  def url
    config.url || "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}"
  end

  def openurl
    config.openurl || "http://www.crossref.org/openurl/?pid=%{pid}&id=doi:%{doi}&noredirect=true"
  end

  def openurl=(value)
    config.openurl = value
  end

  def timeout
    config.timeout || 120
  end

  def workers
    config.workers || 10
  end
end
