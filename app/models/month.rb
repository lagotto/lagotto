class Month < ActiveRecord::Base
  belongs_to :source
  belongs_to :work
  belongs_to :aggregation, inverse_of: :months, touch: true
  has_many :relations, inverse_of: :month

  validates :work_id, :source_id, :aggregation_id, :presence => true
  validates_associated :work, :source, :aggregation
  validates :work_id, uniqueness: { scope: :aggregation_id }

  after_touch :set_total

  default_scope { order("year, month") }

  def set_total
    update_columns(total: relations.sum(:total))
    aggregation.touch
  end

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "month/#{id}-#{timestamp}"
  end
end
