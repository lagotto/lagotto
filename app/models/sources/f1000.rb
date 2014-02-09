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

  # Retrieve PLOS-specific XML feed and store in <filename>. Returns nil if an error occured.
  def get_feed(options={})
    options[:source_id] = id
    save_to_file(url, filename, options)
  end

  def get_data(article, options={})

    # Check that article has DOI
    return  { :events => [], :event_count => nil } if article.doi.blank?

    # Check that XML from f1000 feed exists and isn't older than a day, otherwise an error must have occured
    return nil unless check_file

    document = Nokogiri::XML(File.open("#{Rails.root}/data/#{filename}"))
    result = document.at_xpath("//Article[Doi='#{article.doi}']")

    if result.nil?
      # F1000 doesn't know about the article
      return  { :events => [], :event_count => 0 }
    else
      event = result.to_s
      event = Hash.from_xml(event)
      event = event["Article"]
      event_metrics = { :pdf => nil,
                        :html => nil,
                        :shares => nil,
                        :groups => nil,
                        :comments => nil,
                        :likes => nil,
                        :citations => event["TotalScore"].to_i,
                        :total => event["TotalScore"].to_i }

      { :events => event,
        :events_url => event["Url"],
        :event_count => event["TotalScore"].to_i,
        :event_metrics => event_metrics,
        :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => result.to_s }
      }
    end
  end

  # Check that f1000 XML feed exists and isn't older than a day, otherwise download feed and save as file
  # Returns nil if an error occured
  def check_file
    file = "#{Rails.root}/data/#{filename}"
    if File.exists?(file) and File.file?(file) and File.mtime(file) > 1.day.ago
      return filename
    else
      return get_feed
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "filename", :field_type => "text_field", :size => 90}]
  end

  def filename
    config.filename
  end

  def filename=(value)
    config.filename = value
  end

  def rate_limiting
    config.rate_limiting || 50000
  end

  def workers
    config.workers || 5
  end
end