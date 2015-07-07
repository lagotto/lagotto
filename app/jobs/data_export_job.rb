class DataExportJob < ActiveJob::Base
  queue_as :default

  def perform(options={})
    data_export = DataExport.find_by_id!(options[:id])
    data_export.export!
  rescue Exception => ex
    Alert.create(exception: ex)
  end
end
