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
    if article.doi.nil? || Time.zone.now - article.published_on.to_time < 1.day
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
    return result if result[:error]

    events = get_events(result)

    if article.is_publisher?
      event_count = events.length
    else
      event_count = result.deep_fetch('crossref_result', 'query_result', 'body', 'query', 'fl_count') { 0 }
    end

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: nil,
      event_count: event_count.to_i,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def get_events(result)
    events = result.deep_fetch('crossref_result', 'query_result', 'body', 'forward_link') { nil }
    if events.is_a?(Hash) && events['journal_cite']
      events = [events]
    elsif events.is_a?(Hash)
      events = nil
    end

    Array(events).map do |item|
      item = item.fetch('journal_cite') { {} }
      item.extend Hashie::Extensions::DeepFetch
      url = Article.to_url(item['doi'])
      { event: item,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: item.blank? ? nil : {
          'author' => get_author(item.deep_fetch('contributors', 'contributor') { [] }),
          'title' => item.fetch('article_title') { '' },
          'container-title' => item.fetch('journal_title') { '' },
          'issued' => get_date_parts_from_parts(item['year']),
          'url' => url,
          'type' => 'article-journal' }
        }
    end
  end

  def get_author(contributors)
    contributors = [contributors] if contributors.is_a?(Hash)
    contributors.map do |contributor|
      { 'family' => contributor['surname'],
        'given' => contributor['given_name'] }
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
