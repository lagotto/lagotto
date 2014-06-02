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

class PmcEuropeData < Source
  def get_query_url(article)
    if url.starts_with?("http://www.ebi.ac.uk/europepmc/webservices/rest/MED/")
      return nil unless article.get_ids && article.pmid.present?

      url % { :pmid => article.pmid }
    elsif url.starts_with?("http://www.ebi.ac.uk/europepmc/webservices/rest/search/query")
      return nil unless article.doi.present?

      url % { :doi => article.doi }
    end
  end

  def parse_data(result, article, options={})
    return result if result[:error]
    result = result["responseWrapper"] || result

    event_count = (result["hitCount"]).to_i
    events = get_events(result)

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: get_events_url(article),
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def get_events(result)
    if result["dbCountList"]
      result["dbCountList"]["db"].reduce({}) { |hash, db| hash.update(db["dbName"] => db["count"]) }
    elsif result["resultList"]
      result.extend Hashie::Extensions::DeepFetch
      events = result.deep_fetch('resultList', 'result') { nil }
      events = [events] if events.is_a?(Hash)
      Array(events).map do |item|
        url = item['pmid'] ? "http://europepmc.org/abstract/MED/#{item['pmid']}" : nil
        { event: item,
          event_url: url,

          # the rest is CSL (citation style language)
          event_csl: {
            'author' => get_author(item['authorString']),
            'title' => item.fetch('title') { '' },
            'container-title' => item.fetch('journalTitle') { '' },
            'issued' => get_date_parts_from_parts((item['pubYear']).to_i),
            'url' => url,
            'type' => 'article-journal' }
        }
      end
    else
      []
    end
  end

  def get_events_url(article)
    if article.pmid.present?
      events_url % { :pmid => article.pmid }
    else
      nil
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pmid}/databaseLinks//1/json"
  end

  def events_url
    config.events_url || "http://europepmc.org/abstract/MED/%{pmid}#fragment-related-bioentities"
  end
end
