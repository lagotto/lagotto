class DepositJob < ActiveJob::Base
  include ActiveJob::Retry

  queue_as :default
  variable_retry delays: [1.minute, 5.minutes, 10.minutes, 30.minutes, 60.minutes], retryable_exceptions: RETRYABLE_EXCEPTIONS

  rescue_from StandardError do |exception|
    ActiveRecord::Base.connection_pool.with_connection do
      Notification.where(message: exception.message).where(unresolved: true).first_or_create(
        exception: exception,
        class_name: exception.class.to_s)

      deposit = self.arguments.first
      deposit.error if deposit.present?
    end
  end

  def perform(deposit)
    ActiveRecord::Base.connection_pool.with_connection do
      deposit.start

      if deposit.message_action == 'delete'
        deposit.delete_works
        deposit.delete_events
        deposit.delete_contributors
        deposit.delete_publishers
      else
        deposit.update_works
        deposit.update_events
        deposit.update_contributors
        deposit.update_publishers
      end

      deposit.finish
    end
  end
end
