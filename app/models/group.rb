class Group < ApplicationRecord
  has_many :sources, -> { order(:title) }

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  scope :visible, -> { joins(:sources).where("state > ?", 1).order("groups.id") }
  scope :with_sources, -> { joins(:sources).order("groups.id") }

  def to_param  # overridden, use name instead of id
    name
  end

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "groups/#{name}-#{timestamp}"
  end
end
