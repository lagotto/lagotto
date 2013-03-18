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
    # TODO check for required fields.
    # required fields, solr_url, relative_metric_url

    average_usages = get_relative_metric_data(article)

      event_metrics = { :pdf => nil, 
                        :html => nil, 
                        :shares => nil, 
                        :groups => nil,
                        :comments => nil, 
                        :likes => nil, 
                        :citations => nil, 
                        :total => total }

      { :events => average_usages,
        :event_count => total,
        :event_metrics => event_metrics }

  end

  def get_subject_areas(article)
    # TODO fix url
    url = "http://localhost:8983/solr/select"

    params = {}
    params[:q] = "id:\"#{article.doi}\""
    params[:fl] = 'id,subject_hierarchy'
    params[:wt] = 'json'
    params[:fq] = 'doc_type:full'

    url = "#{url}?#{params.to_query}"

    data = get_json(url)

    # search was a success
    if (data["responseHeader"]["status"] == 0)
      # we found one article
      if (data["response"]["numFound"] == 1)
        raw_subject_areas = data["response"]["docs"][0]["subject_hierarchy"]
      end
    end

    subject_areas = Set.new

    raw_subject_areas.each do | subject_area |

      # example subject area /Biology and life sciences/Anatomy and physiology/Musculoskeletal system/Skeleton/Phalanges

      subject_area_levels = subject_area.split("/")
      # get and remove the first item.  it's an empty string
      subject_area_levels.shift

      if (subject_area_levels.size == 1) 
        first_level = "/#{subject_area_levels[0]}"
        subject_areas << first_level

      elsif (subject_area_levels.size >= 2)
        first_level = "/#{subject_area_levels[0]}"
        second_level = "/#{subject_area_levels[0]}/#{subject_area_levels[1]}"

        subject_areas << first_level
        subject_areas << second_level
      end
    end
    
    return subject_areas
  end

  def get_start_date(article)
    # TODO configure?
    start_year = 2003
    year_interval = 3
    interval = (article.published_on.year - start_year)/year_interval
    return start_year + (year_interval * interval)
  end

  def get_relative_metric_data(article) 
    average_usages = []

    subject_areas = get_subject_areas(article)
    year = get_start_date(article)

    subject_areas.each do | subject_area |
      key = [subject_area, year]
      key_in_json = key.to_json

      # TODO fix url
      url = "http://localhost:5984/relative-metrics2/_design/relative_metric/_view/average_usage?key=#{CGI.escape(key_in_json)}"
      data = get_json(url)

      # there should be only one set of data
      if (data["rows"].size == 1) 
        average_usages << { subject_area => data["rows"][0]["value"] }
      end
    end

    return average_usages
  end

end