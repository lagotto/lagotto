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

  validates_each :url, :filename do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  # Retrieve PLOS-specific XML feed and store in <filename>.
  def get_feed(options={})
    save_to_file(url, filename)
  end
 
  def get_data(article, options={})
    
    # Check that article has DOI
    return  { :events => [], :event_count => nil } if article.doi.blank?

    # Check that F1000 has returned something, otherwise an error must have occured
    file = "#{Rails.root}/data/#{filename}"
    unless File.exists?(file)
      ErrorMessage.create(:exception => "", :class_name => "Errno::ENOENT",
                          :message => "File #{filename} not found", 
                          :status => 404,
                          :source_id => id)
      return nil 
    end

    document = Nokogiri::XML(File.open(file))
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

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end
end