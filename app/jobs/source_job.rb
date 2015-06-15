require 'custom_error'
require 'timeout'

class SourceJob < ActiveJob::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  include CustomError

  queue_as :default

  rescue_from SourceInactiveError do
    # ignore this error
  end

  rescue_from TooManyRequestsError, ActiveRecord::ConnectionTimeoutError, Net::ReadTimeout do
    retry_job wait: 5.minutes
  end

  rescue_from StandardError do |exception|
    rs_ids, source = arguments
    RetrievalStatus.where("id in (?)", rs_ids).update_all(queued_at: nil)
    source_id = source.nil? ? nil : source.id

    Alert.where(message: exception.message).where(unresolved: true).first_or_create(
      exception: exception,
      class_name: exception.class.to_s,
      source_id: source_id)
  end

  def perform(rs_ids, source)
    rs_ids.each do |rs_id|
      # check for failed queries and rate-limiting
      source.work_after_check
      fail SourceInactiveError, "#{source.title} is not in working state" unless source.working?

      # observe rate-limiting settings, put back in queue if wait time is more than 5 sec
      wait_time = source.wait_time
      fail TooManyRequestsError, "Wait time too long (#{wait_time.to_i} sec) for #{source.title}" if wait_time > 5

      sleep wait_time

      rs = RetrievalStatus.where(id: rs_id).first
      fail ActiveRecord::RecordNotFound if rs.nil? || rs.work.nil?

      # store API response result and duration in api_responses table
      response = { work_id: rs.work_id, source_id: rs.source_id, retrieval_status_id: rs.id }
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
end
