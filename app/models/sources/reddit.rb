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

class Reddit < Source
  def parse_data(article, options={})
    result = get_data(article, options)

    return result if result.nil? || result == { events: [], event_count: nil }

    events = result["data"]["children"].map { |item| { event: item["data"], event_url: item["data"]['url'] } }
    events_url = get_events_url(article)
    like_count = result["data"]["children"].empty? ? 0 : result["data"]["children"].reduce(0) { |sum, hash| sum + hash["data"]["score"] }
    comment_count = result["data"]["children"].empty? ? 0 : result["data"]["children"].reduce(0) { |sum, hash| sum + hash["data"]["num_comments"] }
    event_count = like_count + comment_count

    { events: events,
      event_count: event_count,
      events_url: events_url,
      event_metrics: get_event_metrics(comments: comment_count, likes: like_count, total: event_count) }
  end

  def get_query_url(article)
    if article.doi.present?
      url % { :id => CGI.escape(article.doi_escaped) }
    else
      nil
    end
  end

  def get_events_url(article)
    events_url % { :id => CGI.escape(article.doi_escaped) }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://www.reddit.com/search.json?q=\"%{id}\""
  end

  def events_url
    config.events_url || "http://www.reddit.com/search?q=\"%{id}\""
  end

  def rate_limiting
    config.rate_limiting || 1800
  end
end
