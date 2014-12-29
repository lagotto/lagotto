require 'custom_error'
require 'timeout'

class SourceJob < ActiveJob::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  include CustomError

  queue_as :default

  def perform(rs_ids, source)
    source.work_after_check

    # Check that source is working and we have workers for this source
    # Otherwise raise an error and reschedule the job
    fail SourceInactiveError, "#{source.display_name} is not in working state" unless source.working?
    fail NotEnoughWorkersError, "Not enough workers available for #{source.display_name}" unless source.check_for_available_workers

    rs_ids.each do |rs_id|
      rs = RetrievalStatus.find(rs_id)

      # Track API response result and duration in api_responses table
      response = { work_id: rs.work_id, source_id: rs.source_id, retrieval_status_id: rs_id }
      start_time = Time.zone.now
      ActiveSupport::Notifications.instrument("api_response.get") do |payload|
        response.merge!(rs.perform_get_data)
        payload.merge!(response)
      end

      # observe rate-limiting settings
      sleep_interval = start_time + source.job_interval - Time.zone.now
      sleep(sleep_interval) if sleep_interval > 0
    end

    source.wait_after_check
  end

  rescue_from SourceInactiveError, NotEnoughWorkersError do |exception|
    # don't raise error, just postpone perform_later
  end
end
