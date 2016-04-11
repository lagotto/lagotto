class RelationJob < ActiveJob::Base
  queue_as :high

  # don't raise error for ActiveRecord::ConnectionTimeoutError
  rescue_from *RETRYABLE_EXCEPTIONS do |exception|

  end

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Relation.set_month_id
    end
  end
end
