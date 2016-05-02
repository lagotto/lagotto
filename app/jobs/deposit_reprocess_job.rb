class DepositReprocessJob < ActiveJob::Base
  queue_as :high

  def perform(ids)
    ActiveRecord::Base.connection_pool.with_connection do
      Deposit.where(id: ids).find_each { |deposit| deposit.reset }
    end
  end
end
