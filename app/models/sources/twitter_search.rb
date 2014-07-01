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
  def get_query_url(article, options={})
    return nil unless get_access_token && article.doi.present? && article.get_url

    params = { q: "#{article.doi_escaped} OR #{article.canonical_url}",
               count: 100,
               include_entities: 1,
               result_type: "recent" }
    query_url = url + params.to_query
  end

  def request_options
    { bearer: access_token }
  end

  def parse_data(result, article, options = {})
    # return early if an error occured
    return result if result[:error]

    events = get_events(result)
    events = update_events(article, events)

    { events: events,
      events_by_day: get_events_by_day(events, article),
      events_by_month: get_events_by_month(events),
      events_url: get_events_url(article),
      event_count: events.length,
      event_metrics: get_event_metrics(:comments => events.length) }
  end

  def get_events(result)
    Array(result['statuses']).map do |item|
      if item.key?("from_user")
        user = item["from_user"]
        user_name = item["from_user_name"]
        user_profile_image = item["profile_image_url"]
      else
        user = item["user"]["screen_name"]
        user_name = item["user"]["name"]
        user_profile_image = item["user"]["profile_image_url"]
      end

      event_time = get_iso8601_from_time(item['created_at'])
      url = "http://twitter.com/#{user}/status/#{item["id_str"]}"

      { event: { id: item["id_str"],
                 text: item["text"],
                 created_at: event_time,
                 user: user,
                 user_name: user_name,
                 user_profile_image: user_profile_image },
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_author(user_name),
          'title' => item.fetch('text') { '' },
          'container-title' => 'Twitter',
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'personal_communication'
        }
      }
    end
  end

  # check whether we have stored additional tweets in the past
  # merge with new tweets, using tweet URL as unique key
  # we need hash with indifferent access to compare string and symbol keys
  def update_events(article, events)
    data = HashWithIndifferentAccess.new(get_alm_data("twitter_search:#{article.doi_escaped}"))

    merged_events = Array(data['events']) | events
    merged_events.group_by { |event| event[:event][:id] }.map { |k, v| v.first }
  end

  def get_access_token(options={})
    # Check whether we already have an access token
    return true if access_token.present?

    # Otherwise get new access token
    result = get_result(authentication_url, options.merge(
      content_type: 'html',
      username: api_key,
      password: api_secret,
      data: "grant_type=client_credentials",
      source_id: id,
      headers: { "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8" }))

    if result.present? && result["access_token"]
      config.access_token = result["access_token"]
      save
    else
      false
    end
  end

  def config_fields
    [:url, :events_url, :authentication_url, :api_key, :api_secret, :access_token]
  end

  def url
    config.url || "https://api.twitter.com/1.1/search/tweets.json?"
  end

  def events_url
    config.events_url || "https://twitter.com/search?q=%{doi}"
  end

  def authentication_url
    config.authentication_url || "https://api.twitter.com/oauth2/token"
  end

  def authentication_url=(value)
    config.authentication_url = value
  end

  def api_secret
    config.api_secret
  end

  def api_secret=(value)
    config.api_secret = value
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1600
  end

  def staleness_week
    config.staleness_week || 1.day
  end

  def staleness_month
    config.staleness_month || 1.day
  end

  def staleness_year
    config.staleness_year || (1.month * 0.25).to_i
  end

  def staleness_all
    config.staleness_all || (1.month * 0.25).to_i
  end
end
