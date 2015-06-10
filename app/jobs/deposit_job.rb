class DepositJob < ActiveJob::Base
  queue_as :default

  def perform(deposit)
    deposit.start
    deposit.update_works
    deposit.update_events
    deposit.finish
  end
end
