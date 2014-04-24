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

class Wordpress < Source
  def get_data(article, options={})
    # Check that article has DOI
    return  { events: [], event_count: nil } if article.doi.blank?

    query_url = get_query_url(article)
    result = get_result(query_url, options)

    return { events: [], event_count: 0 } if result.nil?

    events = result.map { |item| { event: item, event_url: item['link'] } }

    { events: events,
      event_count: events.length,
      events_url: "http://en.search.wordpress.com/?q=\"#{article.doi}\"&t=post",
      event_metrics: get_event_metrics(citations: events.length) }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://en.search.wordpress.com/?q=\"%{doi}\"&t=post&f=json&size=20"
  end

  def rate_limiting
    config.rate_limiting || 2500
  end
end
