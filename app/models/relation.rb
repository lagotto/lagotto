class Relation < ActiveRecord::Base
  belongs_to :work
  belongs_to :related_work, class_name: "Work", foreign_key: "related_work_id"
  belongs_to :relation_type
  belongs_to :source

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{timestamp}"
  end
end
