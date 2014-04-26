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

class ScienceSeeker < Source
  def parse_data(article, options={})
    result = get_data(article, options)

    return result if result.nil? || result == { events: [], event_count: nil }
    return { events: [], event_count: 0 } if result.empty? || !result["feed"]

    events = Array(result['feed']['entry']).map do |item|
      { :event => item, :event_url => item['link']['href'] }
    end

    events_url = "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi}"

    { :events => events,
      :events_url => events_url,
      :event_count => events.length,
      :event_metrics => get_event_metrics(citations: events.length) }
  end

  def request_options
    { content_type: 'xml' }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=%{doi}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 1000
  end

  def workers
    config.workers || 3
  end
end
