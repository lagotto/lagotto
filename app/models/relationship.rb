class Relationship < ActiveRecord::Base
  belongs_to :work
  belongs_to :related_work, class_name: "Work"
  belongs_to :relation_type
  belongs_to :source

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{timestamp}"
  end
end
