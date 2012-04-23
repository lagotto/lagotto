require 'source_helper'

class SourceJobSkipEnqueue < Struct.new(:article_id, :source, :retrieval_status, :retrieval_history)
  include SourceHelper

  def perform

    article = Article.find(article_id)

    Rails.logger.debug "#{source.name} #{article.doi} perform"

    # check to see if source is active and not disabled
    # if disabled, exit
    unless source.active && (source.disable_until.nil? || source.disable_until < Time.now.utc)
      Rails.logger.debug "#{source.name} not active or disabled"

      retrieval_history.status = RetrievalHistory::SKIPPED_MSG

      msg = []
      unless source.active
        msg << RetrievalHistory::SOURCE_NOT_ACTIVE
      end

      unless (source.disable_until.nil? || source.disable_until < Time.now.utc)
        msg << RetrievalHistory::SOURCE_DISABLED
      end

      retrieval_history.msg = msg.join(",")

      retrieval_history.save
      return
    end

    data_from_source = source.get_data(article, {:retrieval_status => retrieval_status, :timeout => source.timeout })
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
      data_rev = save_alm_data(retrieval_status.data_rev, data.clone, "#{source.name}:#{CGI.escape(article.doi)}")
      retrieval_status.data_rev = data_rev
      retrieval_status.event_count = event_count
      unless local_id.nil?
        retrieval_status.local_id = local_id
      end

      #TODO change this to a copy
      data.delete(:_attachments)
      # save the data to couchdb as retrieval history data
      save_alm_data(nil, data, retrieval_history.id)

      # set retrieval history status to success
      retrieval_history.status = RetrievalHistory::SUCCESS_MSG
      # save the event count in mysql
      retrieval_history.event_count = event_count

    else
      # if we don't get any data, set retrieval history status to success with no data
      retrieval_history.status = RetrievalHistory::SUCCESS_NODATA_MSG
    end

    retrieval_status.retrieved_at = retrieved_at
    retrieval_history.retrieved_at = retrieved_at

    retrieval_status.save
    retrieval_history.save
  end

  def error(job, exception)
    Rails.logger.error "job error #{source.name}:#{article_id} #{exception.message} #{exception.backtrace.join("\n")}"

    retrieval_history.retrieved_at = Time.now.utc
    retrieval_history.status = RetrievalHistory::ERROR_MSG
    retrieval_history.save

    # disable the source if there is an error
    source.disable_until = Time.now.utc + source.disable_delay.seconds
    source.save

  end

end

class SourceJob < SourceJobSkipEnqueue
  include SourceHelper

  def enqueue(job)
    Rails.logger.debug "enqueue #{source.name}:#{article_id}"

    # keep track of when the article was queued up
    retrieval_status.queued_at = Time.now.utc
    retrieval_status.save

  end

  def after(job)
    Rails.logger.debug "job completed #{source.name}:#{article_id}"

    # reset the queued at value
    retrieval_status.queued_at = nil
    retrieval_status.save
  end

end

