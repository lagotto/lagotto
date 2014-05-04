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

class Researchblogging < Source
  def request_options
    { content_type: 'xml', username: username, password: password }
  end

  def get_events(result)
    events = result.deep_fetch('blogposts', 'post') { [] }
    events.map do |item|
      event_time = get_iso8601_from_time(item["published_date"])
      url = item['post_URL']

      { event: item,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_author(item['blogger_name']),
          'title' => item.fetch('post_title') { '' },
          'container-title' => item.fetch('blog_name') { '' },
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'post'
        }
      }
    end
  end

  def config_fields
    [:url, :events_url, :username, :password]
  end

  def url
    config.url || "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{doi}"
  end

  def events_url
    config.events_url || "http://researchblogging.org/post-search/list?article=%{doi}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 2000
  end

  def workers
    config.workers || 3
  end
end
