class StatusCacheJob < ActiveJob::Base
  queue_as :critical

  def perform
    Status.create
  end
end
