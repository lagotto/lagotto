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

    return  { :events => [], :event_count => nil } unless article.get_url

    query_url = get_query_url(article)
    result = get_json(query_url, options)

    if result.nil? or result["data"].nil?
      nil
    else
      events = result["data"]
      # the data we get for the DOI are consistent with the data we get for the URL
      if events[0]["total_count"] == 0 || (events[1]["total_count"]/events[0]["total_count"]).between?(0.8, 1.2)
        shares = events[0]["share_count"]
        comments = events[0]["comment_count"]
        likes = events[0]["like_count"]
        total = events[0]["total_count"]
      else
        shares = 0
        comments = 0
        likes = 0
        total = 0
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
    URI.escape(url % { access_token: access_token, query_url: article.url, doi_as_url: article.doi_as_url })
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "access_token", :field_type => "text_field"}]
  end

  def url
    config.url || "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count, comments_fbid from link_stat where url = '%{query_url}' or url = '%{doi_as_url}'"
  end

  def access_token
    config.access_token
  end
end