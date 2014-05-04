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

class Reddit < Source
  def parse_data(result, article, options={})
    return result if result[:error]

    events = result.deep_fetch('data', 'children') { [] }

    likes = get_sum(events, 'data', 'score')
    comments = get_sum(events, 'data', 'num_comments')
    total = likes + comments

    events = get_events(events)

    { events: events,
      events_by_day: get_events_by_day(events, article),
      events_by_month: get_events_by_month(events),
      events_url: get_events_url(article),
      event_count: total,
      event_metrics: get_event_metrics(comments: comments, likes: likes, total: total) }
  end

  def get_events(result)
    result.map do |item|
      data = item['data']
      event_time = get_iso8601_from_epoch(data['created_utc'])
      url = data['url']

      { event: data,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_author(data['author']),
          'title' => data.fetch('title') { '' },
          'container-title' => 'Reddit',
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'personal_communication'
        }
      }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://www.reddit.com/search.json?q=\"%{doi}\""
  end

  def events_url
    config.events_url || "http://www.reddit.com/search?q=\"%{doi}\""
  end

  def rate_limiting
    config.rate_limiting || 1800
  end
end
