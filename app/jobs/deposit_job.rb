class DepositJob < ActiveJob::Base
  queue_as :default

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform(deposit)
    ActiveRecord::Base.connection_pool.with_connection do
      deposit.process_data
    end
  end
end
