# encoding: UTF-8

require 'timeout'

class RetrievalHistoryJob < Struct.new(:rh_ids)
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  def perform
    rh_ids.each { | rh_id | remove_lagotto_data(rh_id) }
  end

  def error(_job, exception)
    Alert.create(:exception => "", :class_name => exception.class.to_s, :message => exception.message)
  end

  def failure(job)
    # bring error into right format
    error = job.last_error.split("\n")
    message = error.shift
    exception = OpenStruct.new(backtrace: error)

    Alert.create(:class_name => "DelayedJobError", :message => "Failure in #{job.queue}: #{message}", :exception => exception, :source_id => source_id)
  end

  # override the default settings which are:
  # On failure, the job is scheduled again in 5 seconds + N ** 4, where N is the number of retries.
  # with the settings below we try 10 times within one hour, because we then queue jobs again anyway.
  def reschedule_at(time, attempts)
    case attempts
    when (0..4)
      interval = 1.minute
    when (5..6)
      interval = 5.minutes
    else
      interval = 10.minutes
    end
    time + interval
  end
end
