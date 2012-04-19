require 'source_helper'

class RetrievalStatus < ActiveRecord::Base
  include SourceHelper

  belongs_to :article
  belongs_to :source
  has_many :retrieval_histories, :dependent => :destroy

  def get_retrieval_data
    source = Source.find(source_id)
    article = Article.find(article_id)
    begin
      data = get_alm_data("#{source.name}:#{CGI.escape(article.doi)}")
    rescue => e
      Rails.logger.error "Failed to get data for #{source.name}:#{article.doi}.  #{e.message}"
    end
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

end
