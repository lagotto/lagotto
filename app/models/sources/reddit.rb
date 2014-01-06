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

  def get_data(article, options={})

    # Check that article has DOI
    return  { events: [], event_count: nil } if article.doi.blank?

    query_url = get_query_url(article)
    result = get_json(query_url, options)

    if result.nil?
      nil
    else
      events = result["data"]["children"].map { |item| { event: item["data"], event_url: item["data"]['url'] }}
      like_count = result["data"]["children"].empty? ? 0 : result["data"]["children"].inject(0) { |sum, hash| sum + hash["data"]["score"] }
      comment_count = result["data"]["children"].empty? ? 0 : result["data"]["children"].inject(0) { |sum, hash| sum + hash["data"]["num_comments"] }
      event_count = like_count + comment_count
      event_metrics = { pdf: nil,
                        html: nil,
                        shares: nil,
                        groups: nil,
                        comments: comment_count,
                        likes: like_count,
                        citations: nil,
                        total: event_count }

      { events: events,
        event_count: event_count,
        events_url: "http://www.reddit.com/search?q=\"#{CGI.escape(article.doi_escaped)}\"",
        event_metrics: event_metrics }
    end
  end

  def get_query_url(article)
    url % { :id => CGI.escape(article.doi_escaped) }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://www.reddit.com/search.json?q=\"%{id}\""
  end

  def rate_limiting
    config.rate_limiting || 1800
  end
end
