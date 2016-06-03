class DataExportJob < ActiveJob::Base
  queue_as :high

  rescue_from ActiveJob::DeserializationError, ActiveRecord::ConnectionTimeoutError do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform(options={})
    ActiveRecord::Base.connection_pool.with_connection do
      data_export = DataExport.find_by_id!(options[:id])
      data_export.export!
    end
  rescue Exception => ex
    Notification.create(exception: ex)
  end
end
