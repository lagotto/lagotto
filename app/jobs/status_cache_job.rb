class StatusCacheJob < ActiveJob::Base
  queue_as :critical

  def perform
    status = Status.new
    status.write_cache
  end
end
