require 'source_helper'

class SourceJob < Struct.new(:doi, :source, :retrieval_status, :retrieval_history)
  include SourceHelper

  def enqueue(job)
    puts "enqueue #{doi}"

    # keep track of when the article was queued up
    retrieval_status.queued_at = DateTime.now.utc
    retrieval_status.save

  end

  def perform

    puts "#{source.name} #{doi} perform"
    Rails.logger.debug "#{source.name} #{doi} perform"

    # check to see if source is active and not disabled
    # if disabled, exit
    unless source.active && (source.disable_until.nil? || source.disable_until < DateTime.now.utc)
      puts "#{source.name} #{doi} not active or disabled"
      Rails.logger.debug "#{source.name} #{doi} not active or disabled"

      retrieval_history.status = RetrievalHistory::SKIPPED_MSG

      msg = []
      unless source.active
        msg << RetrievalHistory::SOURCE_NOT_ACTIVE
      end

      unless (source.disable_until.nil? || source.disable_until < DateTime.now.utc)
        msg << RetrievalHistory::SOURCE_DISABLED
      end

      retrieval_history.msg = msg.join(",")

      retrieval_history.save
      return
    end

    puts "#{source.name} #{doi} good"
    Rails.logger.debug "#{source.name} #{doi} good"

    puts "#{source.inspect}"
    data_from_source = source.get_data(doi)

    events = data_from_source[0]
    event_count = data_from_source[1]

    retrieved_at = DateTime.now.utc
    if events.length > 0
      data = {}
      data[:doi] = doi
      data[:retrieved_at] = retrieved_at
      data[:source] = source.name
      data[:events] = events;

      # save the data to couchdb
      data_rev = save_alm_data(retrieval_status.data_rev, data.clone, "#{source.name}:#{CGI.escape(doi)}")
      retrieval_status.data_rev = data_rev

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

    puts "#{source.name} #{doi} done"
    Rails.logger.debug "#{source.name} #{doi} done"

  end

  def after(job)
    puts "after #{doi}"

    # reset the queued at value
    retrieval_status.queued_at = nil
    retrieval_status.save
  end

  def error(job, exception)
    puts "error #{doi}"

    retrieval_history.retrieved_at = DateTime.now.utc
    retrieval_history.status = RetrievalHistory::ERROR_MSG
    retrieval_history.error_msg = "#{exception.backtrace.join("\n")}"
    retrieval_history.save

    # disable the source if there is an error
    source.disable_until = DateTime.now.utc + source.disable_delay.seconds
    source.save

  end

end
