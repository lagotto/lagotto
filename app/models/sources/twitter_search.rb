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
  def parse_data(article, options={})
    return nil unless get_access_token

    result = get_data(article, options)

    return result if result.nil? || result == { events: [], event_count: nil }

    events = Array(result['statuses']).map do |item|
      if item.key?("from_user")
        user = item["from_user"]
        user_name = item["from_user_name"]
        user_profile_image = item["profile_image_url"]
      else
        user = item["user"]["screen_name"]
        user_name = item["user"]["name"]
        user_profile_image = item["user"]["profile_image_url"]
      end

      { :event => { id: item["id_str"],
                     text: item["text"],
                     created_at: Time.parse(item["created_at"]).utc.iso8601,
                     user: user,
                     user_name: user_name,
                     user_profile_image: user_profile_image },
        :event_url => "http://twitter.com/#{user}/status/#{item["id_str"]}" }
    end
    events_url = get_events_url(article)

    { events: events,
      event_count: events.length,
      events_url: events_url,
      event_metrics: get_event_metrics(comments: events.length) }
  end

  def request_options
    { bearer: access_token }
  end

  def get_query_url(article, options={})
    if article.doi.present?
      params = { q: article.doi_escaped,
                 count: 100,
                 include_entities: 1,
                 result_type: "mixed" }
      query_url = url + params.to_query
    else
      nil
    end
  end

  def get_access_token(options={})
    # Check whether we already have an access token
    return true if access_token.present?

    # Otherwise get new access token
    result = get_result(authentication_url, options.merge(
      content_type: 'json',
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

  def put_database
    put_alm_data(data_url)
  end

  def get_config_fields
    [{ field_name: "url", field_type: "text_area", size: "90x2" },
     { field_name: "events_url", field_type: "text_area", size: "90x2" },
     { field_name: "data_url", field_type: "text_area", size: "90x2" },
     { :field_name => "authentication_url", :field_type => "text_area", :size => "90x2" },
     { :field_name => "api_key", :field_type => "text_field" },
     { :field_name => "api_secret", :field_type => "text_field" },
     { :field_name => "access_token", :field_type => "text_field" }]
  end

  def get_max_id(next_results)
    query = Rack::Utils.parse_query(next_results)
    query["?max_id"]
  end

  def get_since_id(article)
    rs = retrieval_statuses.where(article_id: article.id).first
    rs.data_rev.to_i # will be 0 the first time
  end

  def set_since_id(article, options={})
    rs = retrieval_statuses.where(article_id: article.id).first
    rs.update_attributes(data_rev: options[:since_id])
  end

  def url
    config.url || "https://api.twitter.com/1.1/search/tweets.json?"
  end

  def events_url
    config.events_url || "https://twitter.com/search?q=%{doi}"
  end

  def data_url
    config.data_url || "http://127.0.0.1:5984/twitter/"
  end

  def data_url=(value)
    config.data_url = value
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

  def staleness_week
    config.staleness_year || 12.hours
  end

  def staleness_year
    config.staleness_year || (1.month * 0.25).to_i
  end

  # Twitter returns 15 results per query
  # They don't use pagination, but the tweet id to loop through results
  # See https://dev.twitter.com/docs/working-with-timelines
  # response = {}
  # since_id = get_since_id(article)
  # max_id = nil
  # result = []

  # begin
  #   query_url = get_query_url(article, max_id: max_id)
  #   response = get_result(query_url, options.merge(bearer: access_token))
  #   if response
  #     max_id = get_max_id(response["search_metadata"]["next_results"])
  #     result += response["statuses"]
  #   end
  # end while response && max_id

  # return nil if response.nil?
end
