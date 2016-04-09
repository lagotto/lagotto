class DeleteWorkJob < ActiveJob::Base
  queue_as :high

  def perform(options = {})
    collection = Work
    collection = collection.where(publisher_id: options[:publisher_id]) unless options[:publisher_id] == "all"
    collection = collection.where(source_id: options[:source_id]) unless options[:source_id] == "all"
    collection.destroy_all
  end
end
