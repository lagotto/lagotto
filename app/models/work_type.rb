class WorkType < ActiveRecord::Base
  has_many :works

  def to_param
    name
  end

  def timestamp
    updated_at.utc.iso8601
  end
end
