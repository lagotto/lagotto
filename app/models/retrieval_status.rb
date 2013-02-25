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

require 'source_helper'

class RetrievalStatus < ActiveRecord::Base
  include SourceHelper

  belongs_to :article, :touch => true
  belongs_to :source
  has_many :retrieval_histories, :dependent => :destroy
  
  serialize :event_metrics
    
  delegate :name, :to => :source

  scope :most_cited, lambda { where("event_count > 0").order("event_count desc").limit(25) }
  scope :most_cited_last_x_days, lambda { |days| joins(:article).where("event_count > 0 AND articles.published_on >= CURDATE() - INTERVAL ? DAY", days).order("event_count desc").limit(25) }
  scope :most_cited_last_x_months, lambda { |months| joins(:article).where("event_count > 0 AND articles.published_on >= CURDATE() - INTERVAL ? MONTH", months).order("event_count desc").limit(25) }
    
  scope :queued, where("queued_at is NOT NULL")
  scope :stale, where("queued_at is NULL AND scheduled_at IS NOT NULL AND scheduled_at <= NOW()")
  scope :published, joins(:article).where("queued_at is NULL AND articles.published_on <= CURDATE()")
  
  scope :total, lambda { |days| where("retrieved_at > NOW() - INTERVAL ? DAY", days) }
  scope :with_events, lambda { |days| where("event_count > 0 AND retrieved_at > NOW() - INTERVAL ? DAY", days) }
  scope :without_events, lambda { |days| where("event_count = 0 AND retrieved_at > NOW() - INTERVAL ? DAY", days) }
  
  scope :by_source, lambda { |source_ids| where(:source_id => source_ids) }
  
  def data
    if event_count > 0
      data = get_alm_data("#{source.name}:#{CGI.escape(article.doi)}")
    else
      nil
    end
  end
  
  def events
    unless data.blank? 
      data["events"] 
    else
      []
    end
  end
  
  def metrics
    unless data.blank? 
      data["event_metrics"] 
    else
      []
    end
  end

  def to_csv
    unless data.nil?
      CSV.generate(:force_quotes => true) do |csv|
        csv << [ "name", "url" ]
        csv << [ source.display_name, data["events_url"] ]

        csv << [""]
        events = data["events"]
        unless events.nil?

          if events.is_a?(Array)
            convert_events_data_to_csv(csv, events)
          elsif events.is_a?(Hash)
            csv << events.keys
            csv << events.values.map {|value| flatten_value(value)}
          end
        end
        csv << [""]
      end
    end
  end

  def convert_events_data_to_csv(csv, events)
    #data
    events.each do |event|
      if event.has_key?("event_url")
        event_data = event["event"]
        if event_data.is_a?(Hash)
          row1 = event["event"].keys
          row2 = event["event"].map {|key, value| flatten_value(value) }
        else
          row1 = ["data"]
          row2 = [event_data]
        end
        row1 << "url"
        row2 << event["event_url"]
      else
        row1 = event.keys
        row2 = event.map {|key, value| flatten_value(value) }
      end
      csv << row1
      csv << row2
    end
  end

  def flatten_value(value)
    # found the code on the web.
    # interesting way to recursively flatten hash and array
    flatten =
        lambda {|r|
          (recurse = lambda {|v|
            if v.is_a?(Hash)
              v.to_a.map{|v| recurse.call(v)}.flatten
            elsif v.is_a?(Array)
              v.flatten.map{|v| recurse.call(v)}
            else
              v.to_s
            end
          }).call(r)
        }

    data = flatten.call(value)

    if data.is_a?(Array)
      return data.flatten.join(" ")
    end

    return data
  end

  def as_json(options={})
    result = {
        :source => source.display_name,
        :updated_at => (retrieved_at.nil? ? nil: retrieved_at.to_time),
        :count => event_count
    }

    if options[:events] == "1" and event_count > 0
      result[:events] = data["events"] if not data.nil?
      result[:public_url] = data["events_url"] if not data.nil? and not data["events_url"].nil?
    end

    result[:histories] = retrieval_histories.map(&:as_json) \
      if options[:history] == "1" and not retrieval_histories.empty?

    result
  end

  def to_xml(options = {})

    options[:indent] ||= 2
    xml = options[:builder] ||= ::Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    attributes = {
        :source => source.display_name,
        :updated_at => (retrieved_at.nil? ? nil: retrieved_at.to_time),
        :count => event_count
    }
    attributes[:public_url] = data["events_url"] if not data.nil? and not data["events_url"].nil?

    xml.tag!("source", attributes) do
      nested_options = options.merge!(:dasherize => false,
                                      :skip_instruct => true)

      if options[:events] == "1" and event_count > 0
        if not data.nil?
          if data["events"].is_a?(Array)
            xml.tag!("events") do
              data["events"].each do |event|
                xml.target! << event.to_xml(:root => "event", :skip_instruct => true )
              end
            end
          elsif data["events"].is_a?(Hash)
            xml.tag!("events") { xml.target! << data["events"].to_xml(:root => "event", :skip_instruct => true ) }
          elsif data["events"].is_a?(String)
            xml.tag!("events", data["events"])
          end
        end
      end

      if options[:history] == "1" and not retrieval_histories.empty?
        xml.tag!("histories") { retrieval_histories.each {|h| h.to_xml(nested_options) } }
      end

    end
  end
  
  def delete_document
    unless data_rev.nil
      document_id = "#{source.name}:#{CGI.escape(article.uid)}"
      remove_alm_data(data_rev, document_id)
    else
      nil
    end
  end
  
  # calculate datetime when retrieval_status should be updated, adding random interval
  def stale_at
    unless article.published_on.nil?
      age_in_days = Time.zone.today - article.published_on
    else
      age_in_days = 366
    end

    if age_in_days < 0
      article.published_on
    elsif (0..7) === age_in_days and source.staleness.length > 1
      random_time(source.staleness[0])
    elsif (8..31) === age_in_days and source.staleness.length > 2
      random_time(source.staleness[1])
    elsif (32..365) === age_in_days and source.staleness.length > 3
      random_time(source.staleness[2])
    else
      random_time(source.staleness.last)
    end
  end
  
  def random_time(duration)
    Time.zone.now + duration + rand(duration/10)
  end
  
end