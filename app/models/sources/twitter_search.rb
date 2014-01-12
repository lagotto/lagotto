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

class TwitterSearch < Source

  def get_data(article, options={})

    return  { events: [], event_count: nil } unless article.get_url

    query_url = get_query_url(article)
    result = get_json(query_url, options.merge(bearer: access_token))

    if result.nil?
      nil
    elsif result.empty? or !result["statuses"]
      { events: [], event_count: nil }
    else
      events = result["statuses"].map do |event|
        if event.has_key?("from_user")
          user = event["from_user"]
          user_name = event["from_user_name"]
          user_profile_image = event["profile_image_url"]
        else
          user = event["user"]["screen_name"]
          user_name = event["user"]["name"]
          user_profile_image = event["user"]["profile_image_url"]
        end

        event_data = { id: event["id_str"],
                       text: event["text"],
                       created_at: event["created_at"],
                       user: user,
                       user_name: user_name,
                       user_profile_image: user_profile_image }

        { :event => event_data,
          :event_url => "http://twitter.com/#{user}/status/#{event["id_str"]}" }
      end
      events_url = get_events_url(article)
      event_metrics = { pdf: nil,
                        html: nil,
                        shares: nil,
                        groups: nil,
                        comments: events.length,
                        likes: nil,
                        citations: nil,
                        total: events.length }

      { events: events,
        event_count: events.length,
        events_url: events_url,
        event_metrics: event_metrics }
    end
  end

  def get_config_fields
    [{ field_name: "url", field_type: "text_area", size: "90x2" },
     { field_name: "events_url", field_type: "text_area", size: "90x2" },
     { field_name: "access_token", field_type: "text_field" }]
  end

  def get_query_url(article)
    url % { :id => article.url }
  end

  def get_events_url(article)
    events_url % { :id => article.url }
  end

  def url
    config.url || "https://api.twitter.com/1.1/search/tweets.json?q=%{id}"
  end

  def events_url
    config.events_url || "https://twitter.com/search?q=%{id}"
  end

  def staleness_week
    config.staleness_year || 12.hours
  end

  def staleness_year
    config.staleness_year || (1.month * 0.25).to_i
  end

  def rate_limiting
    config.rate_limiting || 1600
  end
end