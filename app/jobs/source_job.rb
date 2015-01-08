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

    rs_ids.each do |rs_id|
      rs = RetrievalStatus.find(rs_id)

      # observe rate-limiting settings
      sleep source.wait_time

      # store API response result and duration in api_responses table
      response = { work_id: rs.work_id, source_id: rs.source_id, retrieval_status_id: rs_id }
      ActiveSupport::Notifications.instrument("api_response.get") do |payload|
        response.merge!(rs.perform_get_data)
        payload.merge!(response)
      end
    end
  end

  after_perform do |job|
    rs_ids, source = job.arguments
    RetrievalStatus.where("id in (?)", rs_ids).update_all(queued_at: nil)
    source.wait_after_check
  end

  rescue_from CustomError::SourceInactiveError do |exception|
    # don't raise error, just postpone perform_later
  end

  rescue_from StandardError do |exception|
    rs_ids, source = self.arguments

    Alert.create(exception: exception,
                 class_name: exception.class.to_s,
                 message: exception.message,
                 source_id: source.id)
  end
end
