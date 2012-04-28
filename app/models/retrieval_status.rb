require 'source_helper'

class RetrievalStatus < ActiveRecord::Base
  include SourceHelper

  belongs_to :article
  belongs_to :source
  has_many :retrieval_histories, :dependent => :destroy

  scope :most_cited_sample, lambda { where("event_count > 0").order("event_count desc").limit(5) }

  def get_retrieval_data
    source = Source.find(source_id)
    article = Article.find(article_id)
    data = nil
    begin
      data = get_alm_data("#{source.name}:#{CGI.escape(article.doi)}")
    rescue => e
      Rails.logger.error "Failed to get data for #{source.name}:#{article.doi}.  #{e.message}"
    end
    data
  end

  def to_csv
    if event_count > 0
      retrieval_data = get_retrieval_data
    end

    unless retrieval_data.nil?
      CSV.generate(:force_quotes => true) do |csv|
        csv << [ "name", "url" ]
        csv << [ source.display_name, retrieval_data["events_url"] ]

        csv << [""]
        events = retrieval_data["events"]
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

    if options[:citations] == "1" and event_count > 0
      data = get_retrieval_data
      result[:citations] = data["events"] if not data.nil?
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

    xml.tag!("source", attributes) do
      nested_options = options.merge!(:dasherize => false,
                                      :skip_instruct => true)

      if options[:citations] == "1" and event_count > 0
        data = get_retrieval_data

        if data["events"].is_a?(Array)
          xml.tag!("citations") do
            data["events"].each do |event|
              xml.target! << event.to_xml(:root => "event_data", :skip_instruct => true )
            end
          end
        elsif data["events"].is_a?(Hash)
          xml.tag!("citations") { xml.target! << data["events"].to_xml(:root => "event_data", :skip_instruct => true ) }
        elsif data["events"].is_a?(String)
            xml.tag!("citations", data["events"])
        end
      end

      if options[:history] == "1" and not retrieval_histories.empty?
        xml.tag!("histories") { retrieval_histories.each {|h| h.to_xml(nested_options) } }
      end

    end
  end

  def public_url
    data = get_retrieval_data
    data["events_url"]
  end
end
