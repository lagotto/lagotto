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

class Bloglines < Source
  def get_data(article, options={})
    query_url = get_query_url(article)
    result = get_result(query_url, options.merge(content_type: 'xml'))

    events = []
    result.xpath("//resultset/result").each do |cite|
      event = {}
      %w[site/name site/url site/feedurl title author abstract url].each do |a|
        first = cite.at_xpath("#{a}")
        event[a.gsub('/', '_').intern] = first.content if first
      end
      # Ignore citations of the dx.doi.org URI itself
      events << event \
        unless Article.from_uri(event[:url]) == article.doi
    end

    {:events => events,
     :event_count => events.length,
     :attachment => { :filename => "events.xml", :content_type => "text\/xml", :data => result.to_s } }
  end

  def get_query_url(article)
    title = article.title.gsub(/<\/?[^>]*>/, "")
    config.url % { :username => config.username, :password => config.password, :title => Addressable::URI.encode(title) }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "username", :field_type => "text_field"},
     {:field_name => "password", :field_type => "password_field"}]
  end

  def obsolete?
    true
  end
end
