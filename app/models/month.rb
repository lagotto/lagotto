class Month < ActiveRecord::Base
  belongs_to :source
  belongs_to :work
  belongs_to :event

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

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "month/#{id}-#{timestamp}"
  end
end
