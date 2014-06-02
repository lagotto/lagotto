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

class ArticleCoverageCurated < Source
  def get_query_url(article)
    return nil unless article.doi =~ /^10.1371/

    url % { :doi => article.doi_escaped }
  end

  def response_options
    { metrics: :comments }
  end

  def get_events(result)
    Array(result['referrals']).map do |item|
      event_time = get_iso8601_from_time(item['published_on'])
      url = item['referral']

      { event: item,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => '',
          'title' => item.fetch('title') { '' },
          'container-title' => item.fetch('publication') { '' },
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => get_csl_type(item['type']) }
        }
    end
  end

  def get_csl_type(type)
    return nil if type.blank?

    types = { 'Blog' => 'post',
              'News' => 'article-newspaper',
              'Podcast/Video' => 'broadcast',
              'Lab website/homepage' => 'webpage',
              'University page' => 'webpage' }
    types[type]
  end

  def config_fields
    [:url]
  end
end
