class RegistrationAgency < ActiveRecord::Base
  has_many :works
  has_many :prefixes
  has_many :publishers

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  def to_param  # overridden, use name instead of id
    name
  end

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "registration_agenc/#{name}-#{timestamp}"
  end
end
