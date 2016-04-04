class Relation < ActiveRecord::Base
  # include helper module for query caching
  include Cacheable

  belongs_to :work
  belongs_to :related_work, class_name: "Work"
  belongs_to :relation_type
  belongs_to :month, inverse_of: :relations, touch: true
  belongs_to :source
  belongs_to :publisher

  before_validation :set_occurred_at

  validates :work_id, :related_work_id, :source_id, :relation_type_id, presence: true
  validates :month_id, presence: true, unless: Proc.new { |r| r.implicit }
  validates_associated :work, :source, :relation_type, :month
  validates :work_id, uniqueness: { scope: :month_id }, unless: Proc.new { |r| r.implicit }

  scope :similar, ->(work_id) { where("total > ?", 0) }

  scope :last_x_days, ->(duration) { where("relations.created_at > ?", Time.zone.now.beginning_of_day - duration.days) }
  scope :not_updated, ->(duration) { where("relations.created_at < ?", Time.zone.now.beginning_of_day - duration.days) }

  scope :with_events, -> { where("total > ?", 0) }
  scope :without_events, -> { where("total = ?", 0) }
  scope :most_cited, -> { with_events.order("total desc").limit(25) }
  scope :with_sources, -> { joins(:source).where("sources.active = ?", 1).order("group_id, title") }

  def self.set_month_id
    Relation.where(implicit: false).where(month_id: nil).each do |relation|
      aggregation = Aggregation.where(work_id: relation.related_work_id,
                                      source_id: relation.source_id).first_or_create

      m = Month.where(work_id: relation.related_work_id,
                      source_id: relation.source_id,
                      year: relation.occurred_at.year,
                      month: relation.occurred_at.month,
                      aggregation_id: aggregation.id).first_or_create

      relation.update_attributes(month_id: m.id)
    end
  end

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
end
