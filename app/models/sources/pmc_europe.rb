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

class PmcEurope < Source
  def get_data(article, options={})
    # First, we need to have the pmid for this article.
    # Get it if we don't have it, and proceed only if we do.
    return { events: [], event_count: nil } unless article.get_ids && article.pmid.present?

    query_url = get_query_url(article)
    result = get_result(query_url, options)

    return nil if result.nil?

    event_count = result["hitCount"]

    { events_url: "http://europepmc.org/abstract/MED/#{article.pmid}#fragment-related-citations",
      event_count: event_count,
      event_metrics: event_metrics(citations: event_count) }
  end

  def get_query_url(article)
    url % { :pmid => article.pmid }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pmid}/citations/1/json"
  end
end
