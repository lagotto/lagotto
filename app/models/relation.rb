class Relation < ApplicationRecord
  belongs_to :work
  belongs_to :related_work, class_name: "Work"
  belongs_to :relation_type
  belongs_to :source

  validates :work_id, :presence => true
  validates :related_work_id, :presence => true
  validates :relation_type_id, :presence => true

  scope :referencable, -> { where("level > 0") }
  scope :versionable, -> { where("level = 0") }
  scope :similar, ->(work_id) { where("total > ?", 0) }

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{timestamp}"
  end
end
