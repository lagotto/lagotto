class DeleteCanonicalUrlJob < ActiveJob::Base
  queue_as :high

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform(source)
    # reset all canonical urls
    Work.update_all(canonical_url: nil)
  end
end
