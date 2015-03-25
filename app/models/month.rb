class Month < ActiveRecord::Base
  belongs_to :source
  belongs_to :work
  belongs_to :retrieval_status

  default_scope { order("year, month") }

  # summary metrics, removing nil
  def metrics
    { year: year,
      month: month,
      pdf: pdf,
      html: html,
      readers: readers,
      comments: comments,
      likes: likes,
      total: total }.compact
  end
end
