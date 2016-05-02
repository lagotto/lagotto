require 'custom_error'
require 'timeout'

class AgentJob < ActiveJob::Base
  # include HTTP request helpers
  include Networkable

  include CustomError

  queue_as :default

  # don't raise error for ActiveRecord::ConnectionTimeoutError
  # rescue_from *RETRYABLE_EXCEPTIONS do |exception|

  # end

  # rescue_from(ActiveJob::DeserializationError) do
  #   retry_job wait: 5.minutes, queue: :default
  # end

  # rescue_from(CustomError::AgentInactiveError) do
  #   retry_job wait: 60.minutes, queue: :default
  # end

  def perform(agent, options={})
    ActiveRecord::Base.connection_pool.with_connection do
      if options[:ids].present?
        Array(options[:ids]).each do |id|
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
            response.merge!(agent.collect_data(options.merge(work_id: id)))
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
          response.merge!(agent.collect_data(options))
          payload.merge!(response)
        end
      end
    end
  end

  after_perform do |job|
    ActiveRecord::Base.connection_pool.with_connection do
      agent, _options = job.arguments
      agent.wait_after_check
    end
  end
end
