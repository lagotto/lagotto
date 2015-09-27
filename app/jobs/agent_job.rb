require 'custom_error'
require 'timeout'

class AgentJob < ActiveJob::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  include CustomError

  queue_as :default

  rescue_from AgentInactiveError do
    # ignore this error
  end

  rescue_from TooManyRequestsError do
    retry_job wait: 5.minutes
  end

  rescue_from StandardError do |exception|
    ids, agent = arguments
    agent_id = agent.nil? ? nil : agent.id

    Notification.where(message: exception.message).where(unresolved: true).first_or_create(
      exception: exception,
      class_name: exception.class.to_s,
      agent_id: agent_id)
  end

  def perform(ids, agent, options={})
    case agent.kind
    when "work" then
      Array(ids).each do |id|
        # check for failed queries and rate-limiting
        agent.work_after_check
        fail AgentInactiveError, "#{agent.title} is not in working state" unless agent.working?

        # observe rate-limiting settings, put back in queue if wait time is more than 5 sec
        wait_time = agent.wait_time
        fail TooManyRequestsError, "Wait time too long (#{wait_time.to_i} sec) for #{agent.title}" if wait_time > 5

        sleep wait_time

        work = Work.where(id: id).first
        fail ActiveRecord::RecordNotFound if work.nil?

        # store API response result and duration in api_responses table
        response = { work_id: id, agent_id: agent.id }
        ActiveSupport::Notifications.instrument("api_response.get") do |payload|
          response.merge!(agent.collect_data(id))
          payload.merge!(response)
        end
      end
    else
      # check for failed queries and rate-limiting
      agent.work_after_check
      fail AgentInactiveError, "#{agent.title} is not in working state" unless agent.working?

      # observe rate-limiting settings, put back in queue if wait time is more than 5 sec
      wait_time = agent.wait_time
      fail TooManyRequestsError, "Wait time too long (#{wait_time.to_i} sec) for #{agent.title}" if wait_time > 5

      sleep wait_time

      # store API response result and duration in api_responses table
      response = { agent_id: agent.id }
      ActiveSupport::Notifications.instrument("api_response.get") do |payload|
        response.merge!(agent.collect_data(nil))
        payload.merge!(response)
      end
    end
  end

  after_perform do |job|
    ids, agent = job.arguments
    agent.wait_after_check
  end
end
