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

class Mendeley < Source
  def parse_data(result, article, options={})
    # When Mendeley doesn't return a proper API response it can return
    # - a 404 status and error hash
    # - an empty array
    # - an incomplete hash with just the Mendeley uuid
    # We should handle all 3 cases, but return an error otherwise
    return result if result[:error].is_a?(String)

    events = result.fetch('stats') { {} }

    readers = result.deep_fetch('stats', 'readers') { 0 }
    groups = Array(result['groups']).length
    total = readers + groups

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: result['mendeley_url'],
      event_count: total,
      event_metrics: get_event_metrics(shares: readers, groups: groups, total: total) }
  end

  def get_mendeley_uuid(article, options={})
    # get Mendeley uuid, try pmid first, then doi
    # Otherwise search by title
    # Only use uuid if we also get mendeley_url, otherwise the uuid is broken and we return nil
    # The Mendeley uuid is not persistent, so we need to get it every time

    unless article.pmid.blank?
      result = get_result(get_lookup_url(article), options.merge(bearer: access_token))
      if result.is_a?(Hash) && result['mendeley_url']
        article.update_attributes(:mendeley_uuid => result['uuid'])
        return result['uuid']
      end
    end

    unless article.doi.nil?
      result = get_result(get_lookup_url(article, "doi"), options.merge(bearer: access_token))
      if result.is_a?(Hash) && result['mendeley_url']
        article.update_attributes(:mendeley_uuid => result['uuid'])
        return result['uuid']
      end
    end

    # search by title if we can't get the uuid using the pmid or doi
    unless article.title.blank?
      results = get_result(get_lookup_url(article, "title"), options.merge(bearer: access_token))
      if results.is_a?(Hash) && results['documents']
        documents = results["documents"].select { |document| document["doi"] == article.doi }
        if documents && documents.length == 1 && documents[0]['mendeley_url']
          article.update_attributes(:mendeley_uuid => documents[0]['uuid'])
          return documents[0]['uuid']
        end
      end
    end

    # return nil if we can't get the correct uuid
    nil
  end

  def get_query_url(article)
    # First check that we have a valid OAuth2 access token, and a refreshed uuid
    return nil unless get_access_token && get_mendeley_uuid(article)

    url % { :id => article.mendeley_uuid, :api_key => api_key }
  end

  def get_lookup_url(article, id_type = 'pmid')
    # First check that we have a valid OAuth2 access token
    return nil unless get_access_token

    case id_type
    when "pmid"
      url_with_type % { :id => article.pmid, :doc_type => id_type, :api_key => api_key }
    when "doi"
      url_with_type % { :id => CGI.escape(article.doi_escaped), :doc_type => id_type, :api_key => api_key }
    when "title"
      url_with_title % { :title => CGI.escape("title:#{article.title}"), :api_key => api_key }
    else
      nil
    end
  end

  def get_access_token(options={})
    # Check whether access token is valid for at least another 5 minutes
    return true if access_token.present? && (Time.zone.now + 5.minutes < expires_at.to_time.utc)

    # Otherwise get new access token
    result = get_result(authentication_url, options.merge(
      username: client_id,
      password: secret,
      data: "grant_type=client_credentials",
      source_id: id,
      headers: { "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8" }))

    if result.present? && result["access_token"] && result["expires_in"]
      config.expires_at = Time.zone.now + result["expires_in"].seconds
      config.access_token = result["access_token"]
      save
    else
      false
    end
  end

  def request_options
    { bearer: access_token }
  end

  # Format Mendeley events for all articles as csv
  def to_csv(options = {})
    service_url = "#{CONFIG[:couchdb_url]}_design/reports/_view/mendeley"

    result = get_result(service_url, options)
    return nil if result.blank? || result["rows"].blank?

    CSV.generate do |csv|
      csv << [CONFIG[:uid], "readers", "groups", "total"]
      result["rows"].each { |row| csv << [row["key"], row["value"]["readers"], row["value"]["groups"], row["value"]["readers"] + row["value"]["groups"]] }
    end
  end

  def config_fields
    [:url, :url_with_type, :url_with_title, :authentication_url, :client_id, :secret, :access_token, :expires_at]
  end

  def url
    config.url || "https://api-oauth2.mendeley.com/oapi/documents/details/%{id}"
  end

  def url_with_type
    config.url_with_type || "https://api-oauth2.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}"
  end

  def url_with_type=(value)
    config.url_with_type = value
  end

  def url_with_title
    config.url_with_title || "https://api-oauth2.mendeley.com/oapi/documents/search/title:%{title}/?items=10"
  end

  def url_with_title=(value)
    config.url_with_title = value
  end

  def authentication_url
    config.authentication_url || "https://api-oauth2.mendeley.com/oauth/token"
  end

  def authentication_url=(value)
    config.authentication_url = value
  end

  def client_id
    config.client_id
  end

  def client_id=(value)
    config.client_id = value
  end

  def secret
    config.secret
  end

  def secret=(value)
    config.secret = value
  end

  def expires_at
    config.expires_at || "1970-01-01"
  end

  def expires_at=(value)
    config.expires_at = value
  end
end
