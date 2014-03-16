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

  def get_data(article, options={})

    # Store an empty response if article DOI doesn't resolve to a URL that we can store
    return  { :events => [], :event_count => nil } unless article.get_url

    query_url = get_query_url(article)
    result = get_json(query_url, options)

    if result.nil? or result["data"].nil?
      nil
    else
      events = result["data"]
      # don't trust results if event count is above preset limit
      # workaround for Facebook getting confused about the canonical URL
      if events[0]["total_count"] > count_limit.to_i
        shares = 0
        comments = 0
        likes = 0
        total = 0
      else
        shares = events[0]["share_count"]
        comments = events[0]["comment_count"]
        likes = events[0]["like_count"]
        total = events[0]["total_count"]
      end
      event_metrics = { :pdf => nil,
                        :html => nil,
                        :shares => shares,
                        :groups => nil,
                        :comments => comments,
                        :likes => likes,
                        :citations => nil,
                        :total => total }

      { :events => events,
        :event_count => total,
        :event_metrics => event_metrics }
    end
  end

  def get_query_url(article, options={})
    URI.escape(url % { access_token: access_token, query_url: article.canonical_url_escaped })
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "access_token", :field_type => "text_field"},
     {:field_name => "count_limit", :field_type => "text_field"}]
  end

  def url
    config.url || "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'"
  end

  def access_token
    config.access_token
  end

  def count_limit
    config.count_limit || 20000
  end

  def count_limit=(value)
    config.count_limit = value
  end
end