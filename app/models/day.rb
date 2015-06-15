class Day < ActiveRecord::Base
  belongs_to :source
  belongs_to :work
  belongs_to :retrieval_status

  default_scope { order("year, month, day") }

  # summary metrics, removing nil
  def metrics
    { year: year,
      month: month,
      day: day,
      pdf: pdf,
      html: html,
      readers: readers,
      comments: comments,
      likes: likes,
      total: total }.compact
  end

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "day/#{id}-#{timestamp}"
  end
end
