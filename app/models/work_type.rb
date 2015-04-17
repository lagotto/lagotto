class WorkType < ActiveRecord::Base
  has_many :works, dependent: :nullify

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true, :uniqueness => true

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
