class InsertRetrievalJob < ActiveJob::Base
  queue_as :critical

  def perform(source, ids)
    source.insert_retrievals(ids)
  end
end
