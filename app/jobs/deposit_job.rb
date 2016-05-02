class DepositJob < ActiveJob::Base
  queue_as :default

  # don't raise error for ActiveRecord::ConnectionTimeoutError
  # rescue_from *RETRYABLE_EXCEPTIONS do |exception|

  # end

  # rescue_from(ActiveJob::DeserializationError) do
  #   retry_job wait: 5.minutes, queue: :default
  # end

  def perform(deposit)
    ActiveRecord::Base.connection_pool.with_connection do
      deposit.process_data
    end
  end
end
