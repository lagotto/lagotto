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
  def request_options
    { :headers => { "X-ELS-APIKEY" => api_key, "X-ELS-INSTTOKEN" => insttoken } }
  end

  def parse_data(result, article, options={})
    return result if result[:error]

    events = result.deep_fetch('search-results', 'entry', 0)
    event_count = (events.fetch('citedby-count') { 0 }).to_i

    if event_count > 0
      link = events["link"].find { |link| link["@ref"] == "scopus-citedby" }
      events_url = link["@href"]
    else
      events_url = nil
    end

    { events: events,
      events_url: events_url,
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def config_fields
    [:url, :api_key, :insttoken]
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
