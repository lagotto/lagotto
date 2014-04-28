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
#

class Twitter < Source
  def get_query_url(article)
    if article.doi =~ /^10.1371/
      url % { :doi => article.doi_escaped }
    else
      nil
    end
  end

  def response_options
    { :metrics => :comments }
  end

  def get_events(result)
    Array(result['rows']).map do |item|
      data = item['value']
      if data.key?("from_user")
        user = data["from_user"]
        user_name = data["from_user_name"]
        user_profile_image = data["profile_image_url"]
      else
        user = data["user"]["screen_name"]
        user_name = data["user"]["name"]
        user_profile_image = data["user"]["profile_image_url"]
      end

      { event: { id: data["id_str"],
                 text: data["text"],
                 created_at: Time.parse(data["created_at"]).utc.iso8601,
                 user: user,
                 user_name: user_name,
                 user_profile_image: user_profile_image },
        event_url: "http://twitter.com/#{user}/status/#{data["id_str"]}" }
    end
  end

  def config_fields
    [:url]
  end
end
