class RelationJob < ActiveJob::Base
  queue_as :high

  # don't raise error for ActiveRecord::ConnectionTimeoutError
  rescue_from *RETRYABLE_EXCEPTIONS do |exception|

  end

  rescue_from StandardError do |exception|
    Notification.where(message: exception.message).where(unresolved: true).first_or_create(
                       exception: exception,
                       class_name: exception.class.to_s)
  end

  def perform
    Relation.set_month_id
  end
end
