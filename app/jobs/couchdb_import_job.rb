class CouchdbImportJob < ActiveJob::Base
  queue_as :high

  def perform(ids)
    ids.each do |id|
      event = Event.where(id: id).first
      fail ActiveRecord::RecordNotFound if event.nil? || event.work.nil?

      event.import_from_couchdb
    end
  end
end
