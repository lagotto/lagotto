class ContributionMonthJob < ActiveJob::Base
  queue_as :high

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform
    # add month_id to all contributions
    ActiveRecord::Base.connection_pool.with_connection do
      Contribution.set_month_id
    end
  end
end
