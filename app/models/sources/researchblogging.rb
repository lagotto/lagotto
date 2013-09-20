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

class Researchblogging < Source

  validates_not_blank(:url, :username, :password)

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires username & password") \
      if username.blank? or password.blank?

    # Check that article has DOI
    return  { :events => [], :event_count => nil } if article.doi.blank?

    query_url = get_query_url(article)
    result = get_xml(query_url, options.merge(:username => username, :password => password))

    return nil if result.nil?

    events = []

    total_count = result.at_xpath("//blogposts/@total_records_found")

    result.xpath("//blogposts/post").each do |post|
      event = Hash.from_xml(post.to_s)
      event = event['post']

      events << {:event => event, :event_url => event['post_URL']}
    end

    events_url = get_events_url(article)
    event_metrics = { :pdf => nil,
                      :html => nil,
                      :shares => nil,
                      :groups => nil,
                      :comments => nil,
                      :likes => nil,
                      :citations => total_count.value.to_i,
                      :total => total_count.value.to_i }

    { :events => events,
      :events_url => events_url,
      :event_count => total_count.value.to_i,
      :event_metrics => event_metrics,
      :attachment => events.empty? ? nil : {:filename => "events.xml", :content_type => "text\/xml", :data => result.to_s }}
  end

  def get_events_url(article)
    unless article.doi.blank?
      "http://researchblogging.org/post-search/list?article=#{article.doi_escaped}"
    else
      nil
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "username", :field_type => "text_field"},
     {:field_name => "password", :field_type => "password_field"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

  def username
    config.username
  end
  def username=(value)
    config.username = value
  end

  def password
    config.password
  end

  def password=(value)
    config.password = value
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 1000
  end
end
