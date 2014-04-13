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

class ArticleCoverage < Source

  def get_data(article, options={})

    return  events: [], event_count: nil if article.doi.blank?

    query_url = get_query_url(article)
    result = get_json(query_url, options)

    if result.nil?
      { events: [], event_count: 0 }
    else
      refers = result['referrals']

      if (refers.blank?)
        { events: [], event_count: 0 }
      else
        events = refers.map { |item| { event: item, event_url: item['referral'] } }

        event_metrics = { pdf: nil,
                          html: nil,
                          shares: nil,
                          groups: nil,
                          comments: events.length,
                          likes: nil,
                          citations: nil,
                          total: events.length }

        { events: events,
          event_count: events.length,
          event_metrics: event_metrics }
      end
    end

  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://mediacuration.plos.org/api/v1?doi=%{doi}&state=all"
  end

  def rate_limiting
    config.rate_limiting || 50000
  end

  def workers
    config.workers || 5
  end
end
