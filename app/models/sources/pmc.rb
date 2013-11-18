# encoding: UTF-8

# $HeadURL$
# $Id$
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

class Pmc < Source

  validates_not_blank(:url, :journals, :username, :password)

  def put_pmc_database
    put_alm_data(url)
  end

  # Retrieve usage stats in XML and store in /data directory. Returns nil if an error occured.
  def get_feed(month, year, options={})
    options[:source_id] = id

    journals_array = journals.split(",")
    journals_with_errors = []
    journals_array.each do |journal|
      feed_url = get_feed_url(month, year, journal)
      filename = "pmcstat_#{journal}_#{month}_#{year}.xml"

      if save_to_file(feed_url, filename, options).nil?
        Alert.create(:exception => "", :class_name => "Net::HTTPInternalServerError",
             :message => "PMC Usage stats for journal #{journal}, month #{month}, year #{year} could not be saved",
             :status => 500,
             :source_id => id)
        journals_with_errors << journal
      end
    end
    journals_with_errors
  end

  # Parse usage stats and store in CouchDB
  def parse_feed(month, year, options={})

    journals_array = journals.split(",")
    journals_with_errors = []
    journals_array.each do |journal|
      filename = "pmcstat_#{journal}_#{month}_#{year}.xml"
      file = File.open("#{Rails.root}/data/#{filename}", 'r') { |f| f.read }
      document = Nokogiri::XML(file)

      status = document.at_xpath("//pmc-web-stat/response/@status").value
      if (status != "0")
        error_message = document.at_xpath("//pmc-web-stat/response/error").content
        Alert.create(:exception => "", :class_name => "Net::HTTPInternalServerError",
                     :message => "PMC Usage stats for journal #{journal}, month #{month} and year #{year}: #{error_message}",
                     :status => 500,
                     :source_id => id)
        journals_with_errors << journal
      else
        # go through all the articles in the xml document
        document.xpath("//article").each do |article|
          info = Hash.from_xml(article.to_s)
          doi = info["article"]["meta_data"]["doi"]
          view = info["article"]["usage"]
          view['year'] = year
          view['month'] = month

          # try to get the existing information about the given article
          data = get_json("#{url}#{CGI.escape(doi)}")

          if (data['views'].nil?)
            data = { 'views' => [view] }
          else
            # update existing entry
            data['views'].delete_if { |view| view['month'] == month && view['year'] == year }
            data['views'] << view
          end

          put_alm_data("#{url}#{CGI.escape(doi)}", { :data => data })
        end
      end
    end
    journals_with_errors
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires URL") \
      if url.blank?

    # Check that article has DOI and is at least one day old
    return { :events => [], :event_count => nil } if (article.doi.blank? || Time.zone.now - article.published_on.to_time < 1.day)

    query_url = get_query_url(article)

    Rails.logger.info query_url

    result = get_json(query_url, options)

    Rails.logger.info result

    return nil if result.blank? or !result["views"]

    events = result["views"]

    pdf = events.nil? ? 0 : events.inject(0) { |sum, hash| sum + hash["pdf"].to_i }
    html = events.nil? ? 0 : events.inject(0) { |sum, hash| sum + hash["full_text"].to_i }
    event_count = pdf + html

    event_metrics = { :pdf => pdf,
                      :html => html,
                      :shares => nil,
                      :groups => nil,
                      :comments => nil,
                      :likes => nil,
                      :citations => nil,
                      :total => event_count }

    { :events => events,
      :event_count => event_count,
      :event_metrics => event_metrics }
  end

  def get_query_url(article)
    "#{url}#{article.doi_escaped}"
  end

  def get_feed_url(month, year, journal)
    "http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=#{year}&month=#{month}&jrid=#{journal}&user=#{username}&password=#{password}"
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "journals", :field_type => "text_area", :size => "90x2"},
     {:field_name => "username", :field_type => "text_field"},
     {:field_name => "password", :field_type => "password_field"}]
  end

  def url
    config.url
  end

  def url=(value)
    # make sure we have trailing slash
    config.url = value.chomp("/") + "/"
  end

  def journals
    config.journals
  end

  def journals=(value)
    config.journals = value
  end

  def username
    config.username
  end

  def username=(value)
    config.username = value
  end

  def password
    config.password
  end

  def password=(value)
    config.password = value
  end
end