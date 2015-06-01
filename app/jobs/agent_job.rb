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
    Task.where("id in (?)", ids).update_all(queued_at: nil)
    agent_id = agent.nil? ? nil : agent.id

    Notification.where(message: exception.message).where(unresolved: true).first_or_create(
      exception: exception,
      class_name: exception.class.to_s,
      agent_id: agent_id)
  end

  def perform(ids, agent)
    ids.each do |id|
      # check for failed queries and rate-limiting
      agent.work_after_check
      fail AgentInactiveError, "#{agent.title} is not in working state" unless agent.working?

      # observe rate-limiting settings, put back in queue if wait time is more than 5 sec
      wait_time = agent.wait_time
      fail TooManyRequestsError, "Wait time too long (#{wait_time.to_i} sec) for #{agent.title}" if wait_time > 5

      sleep wait_time

      task = Task.where(id: id).first
      fail ActiveRecord::RecordNotFound if task.nil? || task.work.nil?

      # store API response result and duration in api_responses table
      response = { work_id: task.work_id, agent_id: task.agent_id, task_id: task.id }
      ActiveSupport::Notifications.instrument("api_response.get") do |payload|
        response.merge!(task.perform_get_data)
        payload.merge!(response)
      end
    end
  end

  after_perform do |job|
    ids, agent = job.arguments
    Task.where("id in (?)", ids).update_all(queued_at: nil)
    agent.wait_after_check
  end
end
