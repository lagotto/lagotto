class DepositJob < ActiveJob::Base
  queue_as :default

  def perform(deposit)
    ActiveRecord::Base.connection_pool.with_connection do
      deposit.start

      if deposit.message_action == 'delete'
        deposit.delete_works
        deposit.delete_events
        deposit.delete_contributors
        deposit.delete_publishers
      else
        deposit.update_works
        deposit.update_events
        deposit.update_contributors
        deposit.update_publishers
      end

      deposit.finish
    end
  rescue => error
    deposit.error
    raise error
  end
end
