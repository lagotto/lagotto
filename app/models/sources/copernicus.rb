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

class Copernicus < Source

  def get_data(article, options={})

    return  { :events => [], :event_count => nil } unless article.doi =~ /^10.5194/

    query_url = get_query_url(article)
    result = get_json(query_url, options.merge(:username => username, :password => password))

    if result.nil?
      nil
    elsif result.empty? or !result["counter"]
      { :events => [], :event_count => nil }
    else
      if result["counter"].values.all? { |x| x.nil? }
        event_count = nil
      else
        event_count = result["counter"].values.inject(0) { |sum,x| sum + (x ? x : 0) }
      end
      event_metrics = { :pdf => result["counter"]["PdfDownloads"],
                        :html => result["counter"]["AbstractViews"],
                        :shares => nil,
                        :groups => nil,
                        :comments => nil,
                        :likes => nil,
                        :citations => nil,
                        :total => event_count }

      { :events => result,
        :event_count => event_count,
        :event_metrics => event_metrics }
    end
  end

  def get_query_url(article)
    url % { :doi => article.doi }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "username", :field_type => "text_field"},
     {:field_name => "password", :field_type => "password_field"}]
  end

end
