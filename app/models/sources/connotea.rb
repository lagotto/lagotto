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

class Connotea < Source
  def get_data(article, options={})
    events_url = nil

    query_url = get_query_url(article)
    result = get_xml(query_url, options.merge(:username => username, :password => password))

    events = []
    result.xpath("//default:Post").each do |cite|
      uri = cite.at_xpath("@rdf:about").value
      events << {:event => uri, :event_url => uri}
      events_url = "http://www.connotea.org/uri/" + uri[uri.rindex('/')+1..-1]
    end
    events

    { :events => events,
      :events_url => events_url,
      :event_count => events.length,
      :attachment => { :filename => "events.xml", :content_type => "text\/xml", :data => result.to_s } }
  end

  def get_query_url(article)
    url % { :doi_url => article.doi_as_url }
  end

  def get_config_fields
    [{ :field_name => "url", :field_type => "text_area", :size => "90x2" },
     { :field_name => "username", :field_type => "text_field" },
     { :field_name => "password", :field_type => "password_field" }]
  end

  def obsolete?
    true
  end
end
