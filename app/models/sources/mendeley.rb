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

    # First, we need to have the Mendeley uuid for this article.
    # The Mendeley uuid is not persistent, so we need to get it every time
    mendeley_uuid = get_mendeley_uuid(article, options)
    return  { :events => [], :event_count => nil } if mendeley_uuid.blank?

    article.update_attributes(:mendeley_uuid => mendeley_uuid)

    query_url = get_query_url(article)
    result = get_json(query_url, options)

    # When Mendeley doesn't return a proper API response it can return
    # - a 404 status and error hash
    # - an empty array
    # - an incomplete hash with just the Mendeley uuid
    # We should handle all 3 cases without errors and ignore the result

    if result.blank? or !result['mendeley_url']
      nil
    else
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

      related_articles = get_json(get_related_url(result['uuid']), options)
      result[:related] = related_articles['documents'] if related_articles

      { :events => result,
        :events_url => events_url,
        :event_count => total,
        :event_metrics => event_metrics }
    end
  end

  def get_mendeley_uuid(article, options={})
    # get Mendeley uuid, try pmid first, then doi
    # Otherwise search by title
    # Only use uuid if we also get mendeley_url, otherwise the uuid is broken and we return nil

    unless article.pmid.blank?
      result = get_json(get_query_url(article, "pmid"), options)
      return result['uuid'] if result.is_a?(Hash) and result['mendeley_url']
    end

    unless article.doi.blank?
      result = get_json(get_query_url(article, "doi"), options)
      return result['uuid'] if result.is_a?(Hash) and result['mendeley_url']
    end

    # search by title if we can't get the uuid using the pmid or doi
    unless article.title.blank?
      results = get_json(get_query_url(article, "title"), options)
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

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "url_with_type", :field_type => "text_area", :size => "90x2"},
     {:field_name => "url_with_title", :field_type => "text_area", :size => "90x2"},
     {:field_name => "related_articles_url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "api_key", :field_type => "text_field"}]
  end

  def url
    config.url || "http://api.mendeley.com/oapi/documents/details/%{id}/?consumer_key=%{api_key}"
  end

  def url_with_type
    config.url_with_type || "http://api.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}&consumer_key=%{api_key}"
  end

  def url_with_type=(value)
    config.url_with_type = value
  end

  def url_with_title
    config.url_with_title || "http://api.mendeley.com/oapi/documents/search/title:%{title}/?items=10&consumer_key=%{api_key}"
  end

  def url_with_title=(value)
    config.url_with_title = value
  end

  def related_articles_url
    config.related_articles_url || "http://api.mendeley.com/oapi/documents/related/%{id}?consumer_key=%{api_key}"
  end

  def related_articles_url=(value)
    config.related_articles_url = value
  end

end