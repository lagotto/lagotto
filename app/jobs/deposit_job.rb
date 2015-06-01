class DepositJob < ActiveJob::Base
  queue_as :high

  def perform(deposit)
    deposit.start
    deposit.update_works
    deposit.update_events
    deposit.finish
  end
end
