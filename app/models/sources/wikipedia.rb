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
  # List of Wikipedias to search, we are using 20 most popular wikis
  # Taken from http://toolserver.org/~dartar/cite-o-meter/?doip=10.1371
  LANGUAGES = %w(en de fr it pl es ru ja nl pt sv zh ca uk no fi vi cs hu ko commons)

  validates_each :url do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})

    # Check that article has DOI
    return  { :events => [], :event_count => nil } if article.doi.blank?

    events = {}

    # Loop through the languages
    LANGUAGES.each do |lang|

      host = (lang == "commons") ? "commons.wikimedia.org" : "#{lang}.wikipedia.org"
      query_url = get_query_url(article, :host => host)
      options[:source_id] = id
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
    # doi - the DOI to search for, uses article.doi
    #
    # API Sandbox at http://en.wikipedia.org/wiki/Special:ApiSandbox

    host = options[:host] || "en.wikipedia.org"

    # http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1
    # We search for the DOI in parentheses to only get exact matches
    config.url % { :host => host, :doi => CGI.escape("\"#{article.doi}\"") }
  end

  def get_events_url(article)
    unless article.doi.blank?
      "http://en.wikipedia.org/w/index.php?search=#{CGI.escape("\"#{article.doi}\"")}"
    else
      nil
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

end
