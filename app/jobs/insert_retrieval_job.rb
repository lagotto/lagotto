class InsertRetrievalJob < ActiveJob::Base
  queue_as :critical

  def perform(source)
    source.insert_retrievals
  end
end
