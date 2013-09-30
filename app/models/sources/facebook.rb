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

class Facebook < Source

  validates_not_blank(:url, :access_token)

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires access_token") \
      if access_token.blank?

    # Fetch the fulltext URL
    if article.url.blank? and !article.doi.blank?
      original_url = get_original_url(article.doi_as_url)
      article.update_attributes(:url => original_url) unless original_url.blank?
    end

    return  { :events => [], :event_count => nil } if article.url.blank?

    query_url = get_query_url(article)
    result = get_json(query_url, options)

    if result.nil?
      nil
    else
      events = result["data"][0]
      event_metrics = { :pdf => nil,
                        :html => nil,
                        :shares => events["share_count"],
                        :groups => nil,
                        :comments => events["comment_count"],
                        :likes => events["like_count"],
                        :citations => nil,
                        :total => events["total_count"] }

      { :events => events,
        :event_count => events["total_count"],
        :event_metrics => event_metrics }
    end
  end

  def get_query_url(article, options={})
    URI.escape(url % { :access_token => access_token, :query_url => CGI.escape(article.url) })
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "access_token", :field_type => "text_field"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

  def access_token
    config.access_token
  end

  def access_token=(value)
    config.access_token = value
  end
end
