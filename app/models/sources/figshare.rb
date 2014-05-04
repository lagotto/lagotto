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

class Figshare < Source
  def get_query_url(article)
    return nil unless article.doi =~ /^10.1371/

    url % { :doi => article.doi }
  end

  def parse_data(result, article, options={})
    return result if result[:error]

    events = Array(result["items"])

    views = get_sum(events, 'stats', 'page_views')
    downloads = get_sum(events, 'stats', 'downloads')
    likes = get_sum(events, 'stats', 'likes')

    total = views + downloads + likes

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(pdf: downloads, html: views, likes: likes, total: total) }
  end

  def config_fields
    [:url]
  end
end
