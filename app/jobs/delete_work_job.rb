class DeleteWorkJob < ActiveJob::Base
  queue_as :high

  def perform(publisher_id)
    if publisher_id == "all"
      Work.destroy_all
    elsif publisher_id.present?
      Work.where(publisher_id: publisher_id).destroy_all
    end
  end
end
