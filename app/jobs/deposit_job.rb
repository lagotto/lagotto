class DepositJob < ActiveJob::Base
  queue_as :default

  def perform(deposit)
    ActiveRecord::Base.connection_pool.with_connection do
      deposit.start
      deposit.update_works
      deposit.update_events
      deposit.update_contributors
      deposit.update_publishers
      deposit.finish
    end
  end
end
