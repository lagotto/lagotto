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

class Wikipedia < Source
  # MediaWiki API Sandbox at http://en.wikipedia.org/wiki/Special:ApiSandbox
  def get_query_url(article, options={})
    if article.doi.present?
      host = options[:host] || "en.wikipedia.org"
      namespace = options[:namespace] || "0"
      url % { host: host, namespace: namespace, doi: CGI.escape("\"#{article.doi}\"") }
    else
      nil
    end
  end

  def get_data(article, options={})
    events = {}

    # Loop through the languages
    languages.split(" ").each do |lang|

      host = (lang == "commons") ? "commons.wikimedia.org" : "#{lang}.wikipedia.org"
      namespace = (lang == "commons") ? "6" : "0"
      query_url = get_query_url(article, host: host, namespace: namespace)
      results = get_result(query_url, options)

      # if server doesn't return a result
      if results.nil?
        return nil
      elsif !results.empty? && results['query'] && results['query']['searchinfo'] && results['query']['searchinfo']['totalhits']
        lang_count = results['query']['searchinfo']['totalhits']
      else # not found
        lang_count = 0
      end

      events[lang] = lang_count
    end

    events.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, options={})
    event_count = result.values.reduce(0) { |sum, x| sum + x }
    result["total"] = event_count

    { events: result,
      events_url: get_events_url(article),
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def config_fields
    [:url, :events_url, :languages]
  end

  def url
    config.url || "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1"
  end

  def events_url
    config.events_url || "http://en.wikipedia.org/w/index.php?search=\"%{doi}\""
  end

  def languages
    # Default is 25 largest Wikipedias:
    # https://meta.wikimedia.org/wiki/List_of_Wikipedias#All_Wikipedias_ordered_by_number_of_articles
    config.languages || "en nl de sv fr it ru es pl war ceb ja vi pt zh uk ca no fi fa id cs ko hu ar commons"
  end

  def languages=(value)
    config.languages = value
  end
end
