class CacheJob < ActiveJob::Base
  queue_as :critical

  def perform(resource)
    ActiveRecord::Base.connection_pool.with_connection do
      resource.write_cache
    end
  end
end
