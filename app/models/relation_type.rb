class RelationType < ActiveRecord::Base
  has_many :work_types

  def to_param
    name
  end

  def update_date
    updated_at.utc.iso8601
  end
end
