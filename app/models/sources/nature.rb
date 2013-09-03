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

class Nature < Source

  validates_not_blank(:url)

  def get_data(article, options={})

    # Check that article has DOI
    return  { :events => [], :event_count => nil } if article.doi.blank?

    query_url = get_query_url(article)
    results = get_json(query_url, options)

    if results.nil?
      nil
    else
      events = results.map do |result|
        url = result['post']['url']
        url = "http://#{url}" unless url.start_with?("http://")

        { :event => result['post'], :event_url => url }
      end

      event_metrics = { :pdf => nil,
                        :html => nil,
                        :shares => nil,
                        :groups => nil,
                        :comments => nil,
                        :likes => nil,
                        :citations => events.length,
                        :total => events.length }

      { :events => events,
        :event_count => events.length,
        :event_metrics => event_metrics }
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

  def staleness_year
    config.staleness_year || 1.month
  end

  def max_job_batch_size
    config.max_job_batch_size || 200
  end
end
