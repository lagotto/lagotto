class DataExportJob < ActiveJob::Base
  queue_as :high

  def perform(options={})
    data_export = DataExport.find_by_id!(options[:id])
    data_export.export!
  rescue Exception => ex
    Notification.create(exception: ex)
  end
end
