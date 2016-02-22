class DepositJob < ActiveJob::Base
  queue_as :default

  rescue_from RETRYABLE_EXCEPTIONS do |exception|

  end

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
      deposit.process_data
    end
  end
end
