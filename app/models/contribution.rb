class Contribution < ActiveRecord::Base
  belongs_to :work
  belongs_to :contributor
  belongs_to :contributor_role
  belongs_to :source

  validates :work_id, :presence => true
  validates :contributor_id, :presence => true
  validates :source_id, :presence => true

  scope :last_x_days, ->(duration) { where("contributions.created_at > ?", Time.zone.now.beginning_of_day - duration.days) }

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{timestamp}"
  end
end
