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
  def get_data(article, options={})
    # Check that article has DOI
    return { events: [], event_count: nil } if article.doi.blank?

    query_url = get_query_url(article)
    result = get_result(query_url, options)

    return nil if result.nil?

    events = result.map do |item|
      url = item['post']['url']
      url = "http://#{url}" unless url.start_with?("http://")

      { :event => item['post'], :event_url => url }
    end

    { :events => events,
      :event_count => events.length,
      :event_metrics => get_event_metrics(citations: events.length) }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://blogs.nature.com/posts.json?doi=%{doi}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 5000
  end
end
