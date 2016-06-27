class CacheJob < ActiveJob::Base
  queue_as :critical

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform(resource)
    resource.write_cache
  end
end
