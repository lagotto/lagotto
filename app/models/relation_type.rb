class RelationType < ActiveRecord::Base
  has_many :relations

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  def to_param
    name
  end

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "#{name}/#{timestamp}"
  end
end
