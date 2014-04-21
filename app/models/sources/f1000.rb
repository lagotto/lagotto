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
  def get_data(article, options={})
    # Check that article has DOI
    return { events: [], event_count: nil } if article.doi.blank?

    # Check that most recent F1000 XML exists, otherwise download it
    document = get_feed(options)

    return nil if document.nil?

    result = document.at_xpath("//Article[Doi='#{article.doi}']")

    # F1000 doesn't know about the article
    return  { :events => [], :event_count => 0 } if result.nil?

    event = result.to_s
    event = Hash.from_xml(event)
    event = event["Article"]
    event_count = event["TotalScore"].to_i

    { :events => event,
      :events_url => event["Url"],
      :event_count => event_count,
      :event_metrics => event_metrics(citations: event_count),
      :attachment => { :filename => "events.xml", :content_type => "text\/xml", :data => result.to_s }
    }
  end

  def get_feed(options={})
    # Check that most recent F1000 XML exists, otherwise download it
    file = "#{Rails.root}/data/#{filename}"
    last_time = CronParser.new(cron_line).last(Time.now)

    if File.exists?(file) && File.mtime(file) >= last_time && File.file?(file)
      Nokogiri::XML(File.open(file))
    else
      document = get_xml(url, options.merge(source_id: id))

      return nil if document.nil?

      File.open(file, 'w') { |file| file.write(document.to_s) }
      document
    end
  end

  def get_config_fields
    [{ :field_name => "url", :field_type => "text_area", :size => "90x2" },
     { :field_name => "filename", :field_type => "text_field", :size => 90 }]
  end

  def filename
    config.filename
  end

  def filename=(value)
    config.filename = value
  end

  def rate_limiting
    config.rate_limiting || 1000000
  end

  def workers
    config.workers || 1000
  end

  def cron_line
    config.cron_line || "* 03 * * 3"
  end
end
