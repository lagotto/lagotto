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

require 'custom_error'
require 'timeout'

class SourceJob < Struct.new(:rs_ids, :source_id)
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  include CustomError

  def enqueue(job)
    # keep track of when the article was queued up
    RetrievalStatus.update_all(["queued_at = ?", Time.zone.now], ["id in (?)", rs_ids])
  end

  def perform
    source = Source.find(source_id)
    source.work_after_check

    # Check that source is working and we have workers for this source
    # Otherwise raise an error and reschedule the job
    fail SourceInactiveError, "#{source.display_name} is not in working state" unless source.working?
    fail NotEnoughWorkersError, "Not enough workers available for #{source.display_name}" unless source.check_for_available_workers

    rs_ids.each do | rs_id |
      rs = RetrievalStatus.find(rs_id)

      # Track API response result and duration in api_responses table
      response = { article_id: rs.article_id, source_id: rs.source_id, retrieval_status_id: rs_id }
      start_time = Time.zone.now
      ActiveSupport::Notifications.instrument("api_response.get") do |payload|
        response.merge!(rs.perform_get_data)
        payload.merge!(response)
      end

      # observe rate-limiting settings
      sleep_interval = start_time + source.job_interval - Time.zone.now
      sleep(sleep_interval) if sleep_interval > 0
    end
  end

  def error(job, exception)
    # don't create alert for these errors
    unless exception.kind_of?(SourceInactiveError) || exception.kind_of?(NotEnoughWorkersError)
      Alert.create(exception: "", class_name: exception.class.to_s, message: exception.message, source_id: source_id, level: Alert::WARN)
    end
  end

  def failure(job)
    # bring error into right format
    error = job.last_error.split("\n")
    message = error.shift
    exception = OpenStruct.new(backtrace: error)

    Alert.create(class_name: "DelayedJobError", message: "Failure in #{job.queue}: #{message}", exception: exception, source_id: source_id, level: Alert::FATAL)
  end

  def after(job)
    source = Source.find(source_id)
    RetrievalStatus.update_all(["queued_at = ?", nil], ["id in (?)", rs_ids])
    source.wait_after_check
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
