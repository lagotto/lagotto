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
  def parse_data(result, article, options = {})

    events = get_events(result)

    { events: events,
      events_url: get_events_url(article),
      event_count: events.length,
      event_metrics: get_event_metrics(citations: events.length) }
  end

  def get_events(result)
    Array(result).map { |item| { event: item, event_url: item['link'] } }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://en.search.wordpress.com/?q=\"%{doi}\"&t=post&f=json&size=20"
  end

  def events_url
    config.events_url || "http://en.search.wordpress.com/?q=\"%{doi}\"&t=post"
  end

  def rate_limiting
    config.rate_limiting || 2500
  end
end
