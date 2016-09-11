class ReportJob < ActiveJob::Base
  queue_as :critical

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform(report, template, params, options={})
    ActiveRecord::Base.connection_pool.with_connection do
      report.send_report(template, params, options)
    end
  end
end
