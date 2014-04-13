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

  # Format Mendeley events for all articles as csv
  def self.to_csv(options = {})

    service_url = "#{CONFIG[:couchdb_url]}_design/reports/_view/mendeley"

    result = get_json(service_url, options)
    return nil if result.blank? || result["rows"].blank?

    CSV.generate do |csv|
      csv << ["doi", "readers", "groups", "total"]
      result["rows"].each { |row| csv << [row["key"], row["value"]["readers"], row["value"]["groups"], row["value"]["readers"] + row["value"]["groups"]] }
    end
  end

  def get_data(article, options={})

    # First check that we have a valid OAuth2 access token
    return nil unless get_access_token

    # We then need to have the Mendeley uuid for this article.
    # The Mendeley uuid is not persistent, so we need to get it every time
    mendeley_uuid = get_mendeley_uuid(article, options)
    return  { :events => [], :event_count => nil } if mendeley_uuid.blank?

    article.update_attributes(:mendeley_uuid => mendeley_uuid)

    query_url = get_query_url(article)
    result = get_json(query_url, options.merge(bearer: access_token))

    # When Mendeley doesn't return a proper API response it can return
    # - a 404 status and error hash
    # - an empty array
    # - an incomplete hash with just the Mendeley uuid
    # We should handle all 3 cases without errors and ignore the result

    # an error has occured
    return nil if result.blank?

    # empty array or incomplete hash
    return  { :events => [], :event_count => nil } if !result['mendeley_url']

    # remove "mendeley_authors" key, as it is not needed and creates problems in XML: "mendeley_authors" => {"4712245473"=>5860673}
    result.except!("mendeley_authors")

    events_url = result['mendeley_url']

    # event count is the reader and group numbers combined
    total = 0
    readers = result['stats']['readers'] unless result['stats'].nil?
    total += readers unless readers.nil?

    groups = result['groups']
    total += groups.length unless groups.nil?
    event_metrics = { :pdf => nil,
                      :html => nil,
                      :shares => readers.nil? ? 0 : readers,
                      :groups => groups.nil? ? 0 : groups.length,
                      :comments => nil,
                      :likes => nil,
                      :citations => nil,
                      :total => total }

    related_articles = get_json(get_related_url(result['uuid']), options.merge(bearer: access_token))
    result[:related] = related_articles['documents'] if related_articles

    { :events => result,
      :events_url => events_url,
      :event_count => total,
      :event_metrics => event_metrics }
  end

  def get_mendeley_uuid(article, options={})
    # get Mendeley uuid, try pmid first, then doi
    # Otherwise search by title
    # Only use uuid if we also get mendeley_url, otherwise the uuid is broken and we return nil

    unless article.pmid.blank?
      result = get_json(get_query_url(article, "pmid"), options.merge(bearer: access_token))
      return result['uuid'] if result.is_a?(Hash) and result['mendeley_url']
    end

    unless article.doi.blank?
      result = get_json(get_query_url(article, "doi"), options.merge(bearer: access_token))
      return result['uuid'] if result.is_a?(Hash) and result['mendeley_url']
    end

    # search by title if we can't get the uuid using the pmid or doi
    unless article.title.blank?
      results = get_json(get_query_url(article, "title"), options.merge(bearer: access_token))
      if results.is_a?(Hash) and results['documents']
        documents = results["documents"].select { |document| document["doi"] == article.doi }
        return documents[0]['uuid'] if documents and documents.length == 1 and documents[0]['mendeley_url']
      end
    end

    # return nil if we can't get the correct uuid. We can enter the uuid manually if we have it
    nil
  end

  def get_query_url(article, id_type = nil)
    case id_type
    when nil
      url % { :id => article.mendeley_uuid, :api_key => api_key }
    when "doi"
      url_with_type % { :id => CGI.escape(article.doi_escaped), :doc_type => id_type, :api_key => api_key }
    when "pmid"
      url_with_type % { :id => article.pmid, :doc_type => id_type, :api_key => api_key }
    when "title"
      url_with_title % { :title => CGI.escape("title:#{article.title}"), :api_key => api_key }
    end
  end

  def get_related_url(uuid)
    related_articles_url % { :id => uuid, :api_key => api_key}
  end

  def get_access_token(options={})

    # Check whether access token is valid for at least another 5 minutes
    return true if access_token.present? && (Time.zone.now + 5.minutes < expires_at.to_time.utc)

    # Otherwise get new access token
    result = post_json(authentication_url, options.merge(:username => client_id,
                                                         :password => secret,
                                                         :data => "grant_type=client_credentials",
                                                         :source_id => id,
                                                         :headers => { "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8" }))

    if result.present? && result["access_token"] && result["expires_in"]
      config.expires_at = Time.zone.now + result["expires_in"].seconds
      config.access_token = result["access_token"]
      save
    else
      false
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "url_with_type", :field_type => "text_area", :size => "90x2"},
     {:field_name => "url_with_title", :field_type => "text_area", :size => "90x2"},
     {:field_name => "authentication_url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "related_articles_url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "client_id", :field_type => "text_field"},
     {:field_name => "secret", :field_type => "text_field"},
     {:field_name => "access_token", :field_type => "text_field"},
     {:field_name => "expires_at", :field_type => "hidden_field"}]
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

  def related_articles_url
    config.related_articles_url || "https://api-oauth2.mendeley.com/oapi/documents/related/%{id}"
  end

  def related_articles_url=(value)
    config.related_articles_url = value
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
