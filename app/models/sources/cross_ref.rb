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

class CrossRef < Source
  validates :url, :password, presence: true, if: "CONFIG[:doi_prefix]"

  def get_data(article, options={})
    # Check that article has DOI and is at least one day old
    return { events: [], event_count: nil } if article.doi.blank? || Time.zone.now - article.published_on.to_time < 1.day

    # Check whether we have published the DOI, otherwise use different API
    if article.is_publisher?

      query_url = get_query_url(article)
      result = get_xml(query_url, options)

      return nil if result.nil?

      events = []
      result.xpath("//xmlns:journal_cite").each do |cite|
        event = Hash.from_xml(cite.to_s)
        event = event["journal_cite"]
        event_url = Article.to_url(event["doi"])

        events << { :event => event, :event_url => event_url }
      end

      { :events => events,
        :event_count => events.length,
        :event_metrics => event_metrics(citations: events.length),
        :attachment => events.empty? ? nil : {:filename => "events.xml", :content_type => "text\/xml", :data => result.to_s }}
    else
      get_default_data(article, options={})
    end
  end

  def get_default_data(article, options={})
    query_url = get_default_query_url(article)
    result = get_xml(query_url, options.merge(:source_id => id))

    return nil if result.blank?

    total = result.at_xpath("//@fl_count").value.to_i ||= 0

    {:events => [],
     :event_count => total }
  end

  def get_query_url(article)
    url % { :username => username, :password => password, :doi => article.doi_escaped } unless article.doi.blank?
  end

  def get_default_query_url(article)
    unless article.doi.blank?
      pid = password.blank? ? username : username + ":" + password
      default_url % { :pid => pid, :doi => article.doi_escaped }
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "default_url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "username", :field_type => "text_field"},
     {:field_name => "password", :field_type => "password_field"}]
  end

  def url
    config.url || "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}"
  end

  def default_url
    config.default_url || "http://www.crossref.org/openurl/?pid=%{pid}&id=doi:%{doi}&noredirect=true"
  end

  def default_url=(value)
    config.default_url = value
  end
end
