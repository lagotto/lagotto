class CouchdbImportJob < ApplicationJob
  queue_as :high

  def perform(rs_ids)
    rs_ids.each do |rs_id|
      rs = RetrievalStatus.where(id: rs_id).first
      fail ActiveRecord::RecordNotFound if rs.nil? || rs.work.nil?

      rs.import_from_couchdb
    end
  end
end
