class RelationJob < ActiveJob::Base
  queue_as :high

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Relation.set_month_id
    end
  end
end
