class StatusCacheJob < ActiveJob::Base
  queue_as :critical

  # don't raise error for ActiveRecord::ConnectionTimeoutError
  rescue_from *RETRYABLE_EXCEPTIONS do |exception|

  end

  rescue_from StandardError do |exception|
    ActiveRecord::Base.connection_pool.with_connection do
      Notification.where(message: exception.message).where(unresolved: true).first_or_create(
                         exception: exception,
                         class_name: exception.class.to_s)
    end
  end

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Status.create
    end
  end
end
