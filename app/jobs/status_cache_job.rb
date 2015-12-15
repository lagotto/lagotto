class StatusCacheJob < ActiveJob::Base
  queue_as :critical

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Status.create
    end
  end
end
