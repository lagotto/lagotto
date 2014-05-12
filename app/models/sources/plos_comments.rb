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

class PlosComments < Source
  def get_query_url(article)
    return nil unless article.doi =~ /^10.1371/

    url % { :doi => article.doi }
  end

  def parse_data(result, article, options={})
    return result if result[:error]

    events = get_events(result)
    replies = get_sum(events, :event, 'totalNumReplies')
    total = events.length + replies

    { events: events,
      events_by_day: get_events_by_day(events, article),
      events_by_month: get_events_by_month(events),
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(comments: events.length, total: total) }
  end

  def get_events(result)
    Array(result['data']).map do |item|
      event_time = get_iso8601_from_time(item['created'])

      { event: item,
        event_time: event_time,
        event_url: nil,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_author(item['creatorFormattedName']),
          'title' => item.fetch('title') { '' },
          'container-title' => 'PLOS Comments',
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'personal_communication' }
      }
    end
  end

  def config_fields
    [:url]
  end
end
