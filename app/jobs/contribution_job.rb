class ContributionJob < ActiveJob::Base
  queue_as :high

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform
    # add publisher_id to all contributions
    ActiveRecord::Base.connection_pool.with_connection do
      collection = Contribution.where("publisher_id IS NULL")
      collection.each do |contribution|
        contribution.publisher_id = contribution.work.publisher_id if contribution.work.present?
        contribution.save
      end
    end
  rescue Exception => ex
    Notification.create(exception: ex)
  end
end
