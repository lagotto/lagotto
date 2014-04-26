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
    def parse_data(article, options={})
    result = get_data(article, options)

    return result if result.nil? || result == { events: [], event_count: nil }

    return { events: [], event_count: 0 } if result['referrals'].blank?

    referrals = result['referrals']
    events = referrals.map { |item| { event: item, event_url: item['referral'] } }

    { events: events,
      event_count: events.length,
      event_metrics: get_event_metrics(comments: events.length) }
  end

  def get_query_url(article)
    if article.doi =~ /^10.1371/
      url % { :doi => article.doi_escaped }
    else
      nil
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end
end
