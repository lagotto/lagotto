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

class Datacite < Source

  def get_data(article, options={})

    # Check that article has DOI
    return  { :events => [], :event_count => nil } if article.doi.blank?

    query_url = get_query_url(article)
    result = get_json(query_url, options)

    if result.nil?
      nil
    elsif result.empty? or !result["response"]
      { :events => [], :event_count => nil }
    else
      event_count = result["response"]["numFound"]
      events = result["response"]["docs"].nil? ? [] : result["response"]["docs"].map { |event| { event: event, event_url: "http://doi.org/#{event['doi']}" }}
      event_metrics = { :pdf => nil,
                        :html => nil,
                        :shares => nil,
                        :groups => nil,
                        :comments => nil,
                        :likes => nil,
                        :citations => event_count,
                        :total => event_count }

      { events: events,
        events_url: "http://search.datacite.org/ui?q=relatedIdentifier:#{article.doi_escaped}",
        event_count: event_count,
        event_metrics: event_metrics }
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://search.datacite.org/api?q=relatedIdentifier:%{doi}&fl=relatedIdentifier,doi,creator,title,publisher,publicationYear&fq=is_active:true&fq=has_metadata:true&indent=true&rows=100&wt=json"
  end

end