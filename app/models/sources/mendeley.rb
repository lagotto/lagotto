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

  validates_each :url, :url_with_type, :url_with_title, :related_articles_url, :api_key do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires api key") \
      if config.api_key.blank?

    # First, we need to have the Mendeley uuid for this article.
    # Get it if we don't have it, and proceed only if we do.
    if article.mendeley.blank?
      return  { :events => [], :event_count => nil } if article.doi.blank?
      mendeley = get_mendeley_uuid(article, options)
      article.update_attributes(:mendeley => mendeley) unless mendeley.blank?
      return  { :events => [], :event_count => nil } if article.mendeley.blank?
    end

    result = get_json(get_query_url(article.mendeley), options)

    # When Mendeley doesn't know about an article it can return
    # - a 404 status and error hash
    # - an empty array
    # - an incomplete hash with just the Mendeley uuid
    # We should handle all 3 cases without errors

    if result.nil?
      nil
    elsif result.empty? or !result["stats"]
      { :events => [], :event_count => 0 }
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

    unless article.pub_med.blank?
      result = get_json(get_query_url(article.pub_med, "pmid"), options)
      return result['uuid'] if result.is_a?(Hash) and result['mendeley_url']
    end

    unless article.doi.blank?
      result = get_json(get_query_url(CGI.escape(article.doi_escaped), "doi"), options)
      return result['uuid'] if result.is_a?(Hash) and result['mendeley_url']

      # search by title if we can't get the uuid using the pmid or doi
      results = get_json(get_query_url(CGI.escape(article.title_escaped), "title"), options)
      if results.is_a?(Hash) and results['documents']
        documents = results["documents"].select { |document| document["doi"] == article.doi }
        return documents[0]['uuid'] if documents and documents.length == 1 and documents[0]['mendeley_url']
      end
    end

    # return nil if we can't get the correct uuid. We can enter the uuid manually if we have it
    nil
  end

  def get_query_url(id, id_type = nil)
    if id_type.nil?
      url % { :id => id, :api_key => api_key }
    elsif id_type == "title"
      url_with_title % { :title => id, :api_key => api_key }
    else
      url_with_type % { :id => id, :doc_type => id_type, :api_key => api_key }
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
    config.url
  end

  def url=(value)
    config.url = value
  end

  def url_with_type
    config.url_with_type
  end

  def url_with_type=(value)
    config.url_with_type = value
  end

  def url_with_title
    config.url_with_title
  end

  def url_with_title=(value)
    config.url_with_title = value
  end

  def related_articles_url
    config.related_articles_url
  end

  def related_articles_url=(value)
    config.related_articles_url = value
  end

  def api_key
    config.api_key
  end

  def api_key=(value)
    config.api_key = value
  end
end
