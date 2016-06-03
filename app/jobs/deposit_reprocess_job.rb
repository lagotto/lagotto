class DepositReprocessJob < ActiveJob::Base
  queue_as :high

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform(ids)
    ActiveRecord::Base.connection_pool.with_connection do
      Deposit.where(id: ids).find_each { |deposit| deposit.reset }
    end
  end
end
