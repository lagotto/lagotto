class DepositReprocessJob < ActiveJob::Base
  queue_as :high

  # don't raise error for ActiveRecord::ConnectionTimeoutError
  rescue_from *RETRYABLE_EXCEPTIONS do |exception|

  end

  def perform(ids)
    ActiveRecord::Base.connection_pool.with_connection do
      Deposit.where(id: ids).find_each { |deposit| deposit.reset }
    end
  end
end
