class StatusCacheJob < ActiveJob::Base
  queue_as :critical

  rescue_from ActiveJob::DeserializationError do |exception|
    retry_job wait: 5.minutes
  end

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Status.create
    end
  end
end
