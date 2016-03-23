class Month < ActiveRecord::Base
  belongs_to :source
  belongs_to :work
  belongs_to :aggregation

  default_scope { order("year, month") }

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "month/#{id}-#{timestamp}"
  end
end
