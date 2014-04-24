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
  def get_data(article, options={})
    # Check that article has publisher DOI
    return { events: [], event_count: nil } unless article.is_publisher?

    events = get_relative_metric_data(article)

    return nil if events.blank?

    total = events[:subject_areas].reduce(0) { | sum, subject_area | sum + subject_area[:average_usage].reduce(:+) }

    { :events => events,
      :event_count => total,
      :event_metrics => get_event_metrics(total: total) }
  end

  def get_relative_metric_data(article)
    events = {}

    year = article.published_on.year

    events[:start_date] = "#{year}-01-01T00:00:00Z"
    events[:end_date] = Date.civil(year, -1, -1).strftime("%Y-%m-%dT00:00:00Z")

    query_url = get_query_url(article)
    data = get_result(query_url)

    if data.nil?
      nil
    else
      events[:subject_areas] = data["rows"].map { |row| { :subject_area => row["value"]["subject_area"], :average_usage => row["value"]["data"] } }
      events
    end
  end

  def get_config_fields
    [{ :field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def rate_limiting
    config.rate_limiting || 1000000
  end

  def workers
    config.workers || 1000
  end
end
