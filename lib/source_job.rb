require 'source_helper'

class SourceJob < Struct.new(:doi, :source, :retrieval_status, :retrieval_history)
  include SourceHelper

  def enqueue(job)
    puts "enqueue #{doi}"

    # keep track of when the article was queued up
    retrieval_status.queued_at = DateTime.now.utc
    retrieval_status.save

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
