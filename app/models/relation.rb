class Relation < ActiveRecord::Base
  belongs_to :work
  belongs_to :related_work, class_name: "Work"
  belongs_to :relation_type
  belongs_to :aggregation
  belongs_to :source
  belongs_to :publisher

  before_validation :set_occurred_at

  validates :work_id, :related_work_id, :source_id, :relation_type_id, :aggregation_id, :presence => true

  scope :similar, ->(work_id) { where("total > ?", 0) }

  scope :last_x_days, ->(duration) { where("relations.created_at > ?", Time.zone.now.beginning_of_day - duration.days) }
  scope :not_updated, ->(duration) { where("relations.created_at < ?", Time.zone.now.beginning_of_day - duration.days) }

  scope :with_events, -> { where("total > ?", 0) }
  scope :without_events, -> { where("total = ?", 0) }
  scope :most_cited, -> { with_events.order("total desc").limit(25) }
  scope :with_sources, -> { joins(:source).where("sources.active = ?", 1).order("group_id, title") }

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{timestamp}"
  end

  def self.count_all
    Status.first && Status.first.relations_count
  end

  def set_occurred_at
    occurred_at = Time.zone.now if occurred_at.blank?
  end

  def metrics
    @metrics ||= { total: total }
  end
end
