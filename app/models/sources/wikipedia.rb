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

  validates_not_blank(:url, :languages)

  def get_data(article, options={})

    # Check that article has DOI
    return  { :events => [], :event_count => nil } if article.doi.blank?

    events = {}

    # Loop through the languages
    languages.split(" ").each do |lang|

      host = (lang == "commons") ? "commons.wikimedia.org" : "#{lang}.wikipedia.org"
      namespace = (lang == "commons") ? "6" : "0"
      query_url = get_query_url(article, host: host, namespace: namespace)
      results = get_json(query_url, options)

      # if server doesn't return a result
      if results.nil?
        return nil
      elsif !results.empty? and results['query'] and results['query']['searchinfo'] and results['query']['searchinfo']['totalhits']
        lang_count = results['query']['searchinfo']['totalhits']
      else
        # Not Found
        lang_count = 0
      end

      events[lang] = lang_count
    end

    event_count = events.values.inject(0) { |sum,x| sum + x }
    events["total"] = event_count
    events_url = get_events_url(article)

    event_metrics = { :pdf => nil,
                      :html => nil,
                      :shares => nil,
                      :groups => nil,
                      :comments => nil,
                      :likes => nil,
                      :citations => event_count,
                      :total => event_count }

    { :events => events,
      :event_count => event_count,
      :event_metrics => event_metrics,
      :events_url => events_url }
  end

  def get_query_url(article, options={})
    # Build URL for calling the MediaWiki API, using the following parameters:
    #
    # host - the Mediawiki to search, default en.wikipedia.org (English Wikipedia)
    # namespace - the namespace to search: 0 = pages, 6 = files
    # doi - the DOI to search for, uses article.doi
    #
    # API Sandbox at http://en.wikipedia.org/wiki/Special:ApiSandbox

    host = options[:host] || "en.wikipedia.org"
    namespace = options[:namespace] || "0"

    # We search for the DOI in parentheses to only get exact matches
    url % { host: host, namespace: namespace, doi: "\"#{article.doi}\"" }
  end

  def get_events_url(article)
    unless article.doi.blank?
      "http://en.wikipedia.org/w/index.php?search=\"#{article.doi_escaped}\""
    else
      nil
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "languages", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1"
  end

  def url=(value)
    config.url = value
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
