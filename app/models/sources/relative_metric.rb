#
# Copyright (c) 2009-2013 by Public Library of Science, a non-profit corporation
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

class RelativeMetric < Source
  def get_query_url(article)
    if article.doi =~ /^10.1371/
      url % { :doi => article.doi_escaped }
    else
      nil
    end
  end

  def parse_data(result, article, options={})
    events = get_events(result, article.published_on.year)

    total = events[:subject_areas].reduce(0) { | sum, subject_area | sum + subject_area[:average_usage].reduce(:+) }

    { events: events,
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(total: total) }
  end

  def get_events(result, year)
    { start_date: "#{year}-01-01T00:00:00Z",
      end_date: Date.civil(year, -1, -1).strftime("%Y-%m-%dT00:00:00Z"),
      subject_areas: Array(result["rows"]).map do |row|
        { :subject_area => row["value"]["subject_area"], :average_usage => row["value"]["data"] }
      end }
  end

  def config_fields
    [:url]
  end
end
