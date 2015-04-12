class RelationType < ActiveRecord::Base
  has_many :relations

  def to_param
    name
  end

  def timestamp
    updated_at.utc.iso8601
  end
end
