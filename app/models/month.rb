class Month < ActiveRecord::Base
  belongs_to :source
  belongs_to :work
  belongs_to :retrieval_status

  scope :past, -> { where.not(year: Time.zone.now.year, month: Time.zone.now.month) }

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
