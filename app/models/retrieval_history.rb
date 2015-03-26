class RetrievalHistory < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  belongs_to :retrieval_status
  belongs_to :work
  belongs_to :source

  default_scope { order("retrieved_at DESC") }

  def self.delete_many_documents(options = {})
    number = 0

    start_date = options[:start_date] || (Time.zone.now.to_date - 5.years).to_s
    end_date = options[:end_date] || Time.zone.now.to_date.to_s
    collection = RetrievalHistory.select(:id).where(created_at: start_date..end_date)

    collection.find_in_batches do |rh_ids|
      ids = rh_ids.map(&:id)
      RetrievalHistoryJob.perform_later(ids)
      number += ids.length
    end
    number
  end
end
