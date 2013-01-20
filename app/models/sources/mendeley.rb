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

  validates_each :url, :url_with_type, :related_articles_url, :api_key do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires api key") \
      if config.api_key.blank?
        
    # Check that article has Mendeley uuid, DOI or PubMed ID
    return  { :events => [], :event_count => nil } if article.doi.blank? && article.mendeley.blank? && article.pub_med.blank?
            
    result = []
    options[:source_id] = id
    
    if !article.mendeley.blank?
      result = get_json(get_query_url(article.mendeley), options)
    elsif !article.doi.blank?
      result = get_json(get_query_url(CGI.escape(CGI.escape(article.doi)), "doi"), options)
    elsif !article.pub_med.blank?
      result = get_json(get_query_url(article.pub_med, "pmid"), options)
    else
      return  { :events => [], :event_count => nil }
    end
    
    if result.blank?
      return  { :events => [], :event_count => nil }
    elsif result["error"]
      return  { :events => [], :event_count => 0 }
    else
      events_url = result['mendeley_url']

      # event count is the reader and group numbers combined
      total = 0
      readers = result['stats']['readers'] unless result['stats'].nil?
      total += readers unless readers.nil?

      groups = result['groups']
      total += groups.length unless groups.nil?

      related_articles = get_json(related_url(result['uuid']), options)
      result[:related] = related_articles['documents'] if related_articles.length > 0
      
      # store mendeley uuid and mendeley_url
      article.update_attributes(:mendeley => result['uuid'], :mendeley_url => result['mendeley_url']) 

      { :events => result,
        :events_url => events_url,
        :event_count => total }
    end
  end

  def get_query_url(id, id_type = nil)
    if id_type.nil?
      url % { :id => id, :api_key => config.api_key }
    else
      url_with_type % { :id => id, :doc_type => id_type, :api_key => config.api_key }
    end
  end

  def related_url(uuid)
    config.related_articles_url % { :id => uuid, :api_key => config.api_key}
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "url_with_type", :field_type => "text_area", :size => "90x2"},
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