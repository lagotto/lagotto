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

class PlosComments < Source

  def get_data(article, options={})

    return  { :events => [], :event_count => nil } unless article.doi[0..6] == CONFIG[:doi_prefix].to_s

    query_url = get_query_url(article)
    options[:source_id] = id
    result = get_json(query_url, options)

    if result.nil?
      nil
    elsif !result.kind_of?(Array) || result.empty?
      { :events => [], :event_count => nil }
    else
      events = result
      replies = events.inject(0) { |sum, hash| sum + hash["totalNumReplies"].to_i }
      total = events.length + replies
      event_metrics = { :pdf => nil,
                        :html => nil,
                        :shares => nil,
                        :groups => nil,
                        :comments => events.length,
                        :likes => nil,
                        :citations => nil,
                        :total => total }

      { :events => events,
        :event_count => total,
        :event_metrics => event_metrics }
    end
  end

  def get_query_url(article)
    url % { :doi => article.doi }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://api.plosjournals.org/v1/articles/%{doi}?comments"
  end

  def rate_limiting
    config.rate_limiting || 36000
  end
end