class InsertRetrievalJob < ApplicationJob
  queue_as :critical

  def perform(source)
    source.insert_retrievals
  end
end
