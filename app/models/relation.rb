class Relation < ActiveRecord::Base
  belongs_to :work
  belongs_to :related_work, class_name: "Work"
  belongs_to :relation_type
  belongs_to :source
  belongs_to :publisher

  before_create :set_occurred_at

  validates :work_id, :presence => true
  validates :related_work_id, :presence => true
  validates :relation_type_id, :presence => true

  scope :referencable, -> { where("level = 1") }
  scope :versionable, -> { where("level = 0") }
  scope :similar, ->(work_id) { where("total > ?", 0) }
  scope :last_x_days, ->(duration) { where("relations.created_at > ?", Time.zone.now.beginning_of_day - duration.days) }

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
    write_attribute(:occurred_at, Time.zone.now) if occurred_at.blank?
  end
end
