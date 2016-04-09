class DepositJob < ActiveJob::Base
  queue_as :default

  # don't raise error for ActiveRecord::ConnectionTimeoutError
  rescue_from *RETRYABLE_EXCEPTIONS do |exception|

  end

  rescue_from StandardError do |exception|
    Notification.where(message: exception.message).where(unresolved: true).first_or_create(
                       exception: exception,
                       class_name: exception.class.to_s)

    # deposit = self.arguments.first
    # deposit.error if deposit.present?
  end

  def perform(deposit)
    deposit.process_data
  end
end
