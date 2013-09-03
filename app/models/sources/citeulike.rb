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

class Citeulike < Source

  validates_not_blank(:url)

  def get_data(article, options={})

    # Check that article has DOI
    return  { :events => [], :event_count => nil } if article.doi.blank?

    query_url = get_query_url(article)
    result = get_xml(query_url, options)

    return nil if result.nil?

    events = []
    result.xpath("//post").each do |post|
      event = Hash.from_xml(post.to_s)
      event = event['post']
      events << {:event => event, :event_url => event['link']['url']}
    end

    events_url = get_events_url(article)

    event_metrics = { :pdf => nil,
                      :html => nil,
                      :shares => events.length,
                      :groups => nil,
                      :comments => nil,
                      :likes => nil,
                      :citations => nil,
                      :total => events.length }

    { :events => events,
      :events_url => events_url,
      :event_count => events.length,
      :event_metrics => event_metrics,
      :attachment => events.empty? ? nil : {:filename => "events.xml", :content_type => "text\/xml", :data => result.to_s }}
  end

  def get_events_url(article)
    unless article.doi.blank?
      "http://www.citeulike.org/doi/#{article.doi}"
    else
      nil
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

  def max_job_batch_size
    config.max_job_batch_size || 2000
  end

end
