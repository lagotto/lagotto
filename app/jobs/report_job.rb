class ReportJob < ActiveJob::Base
  queue_as :critical

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform(report, template, options={})
    ActiveRecord::Base.connection_pool.with_connection do
      logger.debug report.send_report(template, options)
    end
  end
end
