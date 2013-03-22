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

  if APP_CONFIG["doi_prefix"]
    validates_each :url, :solr_url do |record, attr, value|
      record.errors.add(attr, "can't be blank") if value.blank?
    end
  end

  def get_data(article, options={})
    # Check that article has DOI
    return { :events => [], :event_count => nil } if article.doi.blank?

    # Check whether we have published the DOI, otherwise use different API
    if article.is_publisher?

      raise(ArgumentError, "#{display_name} configuration require url and solr url") \
        if config.url.blank? or config.solr_url.blank?

      events = get_relative_metric_data(article)

      total = 0
      events[:subject_areas].each do | subject_area |
        total += subject_area[:average_usage].reduce(:+)
      end

      event_metrics = { :pdf => nil,
                        :html => nil,
                        :shares => nil,
                        :groups => nil,
                        :comments => nil,
                        :likes => nil,
                        :citations => nil,
                        :total => total }

      { :events => events,
        :event_count => total,
        :event_metrics => event_metrics }
    
    else
      { :events => [], :event_count => nil }
    end
  end

  def get_subject_areas(article)
    url = config.solr_url

    params = {}
    params[:q] = "id:\"#{article.doi}\""
    params[:fl] = 'id,subject_hierarchy'
    params[:wt] = 'json'
    params[:fq] = 'doc_type:full'

    url = "#{url}?#{params.to_query}"

    data = get_json(url)

    raw_subject_areas = []
    if (data["responseHeader"]["status"] == 0)
      # search was a success
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

  def get_start_year(article)
    # TODO configure?
    start_year = 2003
    year_interval = 3
    interval = (article.published_on.year - start_year)/year_interval
    return start_year + (year_interval * interval)
  end

  def get_relative_metric_data(article) 
    events = {}

    subject_areas = get_subject_areas(article)
    year = get_start_year(article)

    events[:start_date] = "#{year}-01-01T00:00:00Z"
    events[:end_date] = Date.civil(year + 2, -1, -1).strftime("%Y-%m-%dT00:00:00Z")

    average_usages = []

    subject_areas.each do | subject_area |
      key = [subject_area, year]

      url = config.url % { :key => CGI.escape(key.to_json) }
      data = get_json(url)

      # there should be only one set of data
      if (data["rows"].size == 1) 
        if (data["rows"][0]["value"].size > 0) 
          average_usages << { :subject_area => subject_area, :average_usage => data["rows"][0]["value"] }
        end
      end
    end
    
    events[:subject_areas] = average_usages

    return events
  end

  def get_config_fields
    [
      { :field_name => "url", :field_type => "text_area", :size => "90x2"}, 
      { :field_name => "solr_url", :field_type => "text_area", :size => "90x2"}
    ]
  end

  def url
    config.url
  end
  
  def url=(value)
    config.url = value
  end

  def solr_url
    config.solr_url
  end

  def solr_url=(value)
    config.solr_url = value
  end
end
