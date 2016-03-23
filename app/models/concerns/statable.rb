module Statable
  extend ActiveSupport::Concern

  included do
    state_machine :initial => :available do
      state :available, value: 0 # agent available, but not installed
      state :retired, value: 1   # agent installed, but no longer accepting new data
      state :inactive, value: 2  # agent disabled by admin
      state :disabled, value: 3  # can't queue or process jobs, generates alert
      state :waiting, value: 5   # agent active, waiting for next job
      state :working, value: 6   # processing jobs

      state all - [:available, :retired, :inactive] do
        def active?
          true
        end
      end

      state all - [:working, :waiting, :disabled] do
        def active?
          false
        end
      end

      state all - [:available, :retired, :inactive, :disabled] do
        def updating?
          true
        end
      end

      state all - [:working, :waiting] do
        def updating?
          false
        end
      end

      state all - [:available, :retired, :inactive] do
        validate { |agent| agent.validate_config_fields }
      end

      state all - [:available] do
        def installed?
          true
        end
      end

      state :available do
        def installed?
          false
        end
      end

      after_transition :available => any - [:available, :retired] do |agent|
        CacheJob.perform_later(agent)
      end

      after_transition :to => :inactive do |agent|
        agent.remove_queues
      end

      after_transition any - [:disabled] => :disabled do |agent|
        if agent.check_for_rate_limits
          class_name = "Net::HTTPTooManyRequests"
          message = "#{agent.title} has exceeded the rate-limiting of requests. Disabling the agent."
        else
          class_name = "TooManyErrorsBySourceError"
          message = "#{agent.title} has exceeded maximum failed queries. Disabling the agent."
        end
        Notification.where(message: message).where(unresolved: true).first_or_create(
          exception: "",
          class_name: class_name,
          source_id: agent.source_id,
          level: Notification::FATAL)
      end

      event :install do
        transition [:available] => :retired, :if => :obsolete?
        transition [:available] => :inactive
      end

      event :uninstall do
        transition any - [:available] => :retired, :if => :obsolete?
        transition any - [:available] => :available
      end

      event :activate do
        transition [:available] => :retired, :if => :obsolete?
        transition [:available, :inactive] => :waiting
        transition any => same
      end

      event :inactivate do
        transition any => :inactive
      end

      event :disable do
        transition any => :disabled
      end

      event :work_after_check do
        transition [:available, :retired, :inactive] => same
        transition any => :disabled, :if => :check_for_failures
        transition any => :disabled, :if => :check_for_rate_limits
        transition any => :working
      end

      event :work do
        transition [:waiting] => :working
        transition any => same
      end

      event :wait_after_check do
        transition :disabled => same
        transition any => :waiting
      end

      event :wait do
        transition any => :waiting
      end
    end
  end
end
