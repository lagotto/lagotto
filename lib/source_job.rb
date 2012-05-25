require 'source_helper'

class SourceJob < Struct.new(:rs_ids, :source_id)
  include SourceHelper

  def enqueue(job)
    Rails.logger.debug "enqueue #{rs_ids.inspect}"

    # keep track of when the article was queued up
    RetrievalStatus.update_all(["queued_at = ?", Time.now.utc], ["id in (?)", rs_ids.map(&:id)] )
  end

  def perform

    # check to see if source is active and not disabled
    # if disabled, exit
    source = Source.find(source_id)
    unless source.active && (source.disable_until.nil? || source.disable_until < Time.now.utc)
      Rails.logger.info "#{source.name} not active or disabled"
      return
    end

    rs_ids.each do | rs_id |
      unless source.active && (source.disable_until.nil? || source.disable_until < Time.now.utc)
        Rails.logger.info "#{source.name} not active or disabled"
        return
      end

      perform_get_data(rs_id, source)
    end

  end

  def perform_get_data(rs_id, source)

    rs = RetrievalStatus.find(rs_id)

    article = Article.find(rs.article_id)

    rh = RetrievalHistory.new
    rh.retrieval_status_id = rs.id
    rh.article_id = rs.article_id
    rh.source_id = source.id
    rh.save

    Rails.logger.debug "#{source.name} #{article.doi} perform"

    begin
      data_from_source = source.get_data(article, {:retrieval_status => rs, :timeout => source.timeout })
      if data_from_source.class == Hash
        events = data_from_source[:events]
        events_url = data_from_source[:events_url]
        event_count = data_from_source[:event_count]
        local_id = data_from_source[:local_id]
        attachment = data_from_source[:attachment]
      end

      retrieved_at = Time.now.utc
      if !events.nil? && events.length > 0
        data = {}
        data[:doi] = article.doi
        data[:retrieved_at] = retrieved_at
        data[:source] = source.name
        data[:events] = events
        data[:events_url] = events_url

        if !attachment.nil?

          if !attachment[:filename].nil? && !attachment[:content_type].nil? && !attachment[:data].nil?
            data[:_attachments] = {attachment[:filename] => {"content_type" => attachment[:content_type],
                                                             "data" => Base64.encode64(attachment[:data]).gsub(/\n/, '')}}
          end
        end

        # save the data to couchdb
        data_rev = save_alm_data(rs.data_rev, data.clone, "#{source.name}:#{CGI.escape(article.doi)}")
        rs.data_rev = data_rev
        rs.event_count = event_count
        unless local_id.nil?
          rs.local_id = local_id
        end

        #TODO change this to a copy
        data.delete(:_attachments)
        # save the data to couchdb as retrieval history data
        save_alm_data(nil, data, rh.id)

        # set retrieval history status to success
        rh.status = RetrievalHistory::SUCCESS_MSG
        # save the event count in mysql
        rh.event_count = event_count

      else
        # if we don't get any data, set retrieval history status to success with no data
        rh.status = RetrievalHistory::SUCCESS_NODATA_MSG
      end

      rs.retrieved_at = retrieved_at
      rh.retrieved_at = retrieved_at

      rs.save
      rh.save
    rescue
      rh.retrieved_at = Time.now.utc
      rh.status = RetrievalHistory::ERROR_MSG
      rh.save

      # disable the source if there is an error
      source.disable_until = Time.now.utc + source.disable_delay.seconds
      source.save
    end

  end

  def error(job, exception)
    Rails.logger.error "job error #{exception.message} #{exception.backtrace.join("\n")}"
  end

  def after(job)
    Rails.logger.debug "job completed"

    #reset the queued at value
    RetrievalStatus.update_all(["queued_at = ?", nil], ["id in (?)", rs_ids.map(&:id)] )
  end

end

