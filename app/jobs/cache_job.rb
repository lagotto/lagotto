class CacheJob < ActiveJob::Base
  queue_as :critical

  # don't raise error for ActiveRecord::ConnectionTimeoutError
  rescue_from *RETRYABLE_EXCEPTIONS do |exception|

  end

  def perform(resource)
    ActiveRecord::Base.connection_pool.with_connection do
      resource.write_cache
    end
  end
end
