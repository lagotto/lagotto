class StatusCacheJob < ApplicationJob
  queue_as :critical

  def perform
    Status.create
  end
end
