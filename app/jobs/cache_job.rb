class CacheJob < ActiveJob::Base
  queue_as :critical

  def perform(resource)
    resource.write_cache
  end
end
