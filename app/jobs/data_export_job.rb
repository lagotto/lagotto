class DataExportJob < ActiveJob::Base
  queue_as :high

  def perform(options={})
    ActiveRecord::Base.connection_pool.with_connection do
      data_export = DataExport.find_by_id!(options[:id])
      data_export.export!
    end
  rescue Exception => ex
    Notification.create(exception: ex)
  end
end
