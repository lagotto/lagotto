# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
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

class Scopus < Source
  def parse_data(article, options={})
    result = get_data(article, options)

    return result if result.nil? || result == { events: [], event_count: nil }

    if result["search-results"].nil? || result["search-results"]["entry"][0].nil?
      nil
    elsif result["search-results"]["entry"][0]["citedby-count"].nil?
      { events: [], event_count: 0, event_metrics: get_event_metrics(citations: 0) }
    else
      events = result["search-results"]["entry"][0]
      event_count = events["citedby-count"].to_i
      link = events["link"].find { |link| link["@ref"] == "scopus-citedby" }

      { events: events,
        events_url: link["@href"],
        event_count: event_count,
        event_metrics: get_event_metrics(citations: event_count) }
    end
  end

  def request_options
    { :headers => { "X-ELS-APIKEY" => api_key, "X-ELS-INSTTOKEN" => insttoken } }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     { field_name: "api_key", field_type:  "text_field" },
     { field_name: "insttoken", field_type: "text_field" }]
  end

  def url
    config.url  || "https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(%{doi})"
  end

  def insttoken
    config.insttoken
  end

  def insttoken=(value)
    config.insttoken = value
  end
end
