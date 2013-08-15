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

class Pmc < Source

  validates_each :url, :filepath do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} requires url") \
      if config.url.blank?

    query_url = get_query_url(article)

    events = nil
    event_count = 0
    results = []

    results = get_json(query_url, options)

    if results.nil?       
      nil
    elsif results.empty? or !results["views"]
      { :events => [], :event_count => 0 }
    else
      events = results["views"]

      # the event count will be the sum of all the full-text values and pdf values
      unless events.nil?
        event_count = 0
        events.each do | event |
          event_count += event['full-text'].to_i + event['pdf'].to_i
        end
      end
    end
    
    event_metrics = { :pdf => events.nil? ? nil : events.inject(0) { |sum, hash| sum + hash["pdf"].to_i }, 
                      :html => events.nil? ? nil : events.inject(0) { |sum, hash| sum + hash["full-text"].to_i }, 
                      :shares => nil, 
                      :groups => nil,
                      :comments => nil, 
                      :likes => nil, 
                      :citations => nil, 
                      :total => event_count }

    { :events => events, 
      :event_count => event_count,
      :event_metrics => event_metrics }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "filepath", :field_type => "text_field", :size => 90}]
  end

  def filepath
    config.filepath
  end

  def filepath=(value)
    config.filepath = value
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end
end