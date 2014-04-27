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

class F1000 < Source
  def parse_data(article, options={})
    result = get_data(article, options)

    return { events: [], event_count: 0 } if result.nil?
    return result if result == { events: [], event_count: nil }

    event_count = result["TotalScore"].to_i
    events_url = result["Url"]

    { :events => result,
      :events_url => events_url,
      :event_count => event_count,
      :event_metrics => get_event_metrics(citations: event_count) }
  end

  # Retrieve f1000 XML feed and store in /data directory.
  def get_feed(options={})
    save_to_file(feed_url, filename, options.merge(source_id: id))
  end

  # Parse f1000 feed and store in CouchDB. Returns an empty array if no error occured
  def parse_feed(options={})
    document = read_from_file(filename)
    Array(document['ObjectList']['Article']).each do |article|
      # sometimes doi metadata are missing
      break unless article['Doi']

      # store information in CouchDB
      put_alm_data("#{url}#{CGI.escape(article['Doi'])}", data: article)
    end
  end

  def put_database
    put_alm_data(url)
  end

  def request_options
    { content_type: 'xml', source_id: id }
  end

  def get_query_url(article)
    if article.doi.present?
      url % { :doi => article.doi_escaped }
    else
      nil
    end
  end

  def get_feed_url
    feed_url
  end

  def get_config_fields
    [{ :field_name => "url", :field_type => "text_area", :size => "90x2" },
     { field_name: "feed_url", field_type: "text_area", size: "90x2" },
     { :field_name => "filename", :field_type => "text_field", :size => 90 }]
  end

  def filename
    config.filename
  end

  def filename=(value)
    config.filename = value
  end

  def url
    config.url || "http://127.0.0.1:5984/f1000/"
  end

  def url=(value)
    config.url = value
  end

  def cron_line
    config.cron_line || "* 02 * * 1"
  end
end
