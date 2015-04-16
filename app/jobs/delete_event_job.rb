class DeleteEventJob < ActiveJob::Base
  queue_as :high

  def perform(source)
    # only delete related works if they are not linked via other sources
    work_ids = Relationship.where(source_id: source.id).select(:work_id, :related_work_id).group(:work_id, :related_work_id).having("count(*) = 1").pluck(:work_id)
    Work.where(id: work_ids).destroy_all
    source.relationships.destroy_all

    # reset metrics to zero and delete all
    source.retrieval_statuses.update_all(total: 0, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0)
    source.months.destroy_all
    source.days.destroy_all
    source.write_cache
  end
end
