class CacheJob < ActiveJob::Base
  queue_as :critical

  rescue_from ActiveJob::DeserializationError do |exception|
    retry_job wait: 5.minutes
  end

  def perform(resource)
    ActiveRecord::Base.connection_pool.with_connection do
      resource.write_cache
    end
  end
end
