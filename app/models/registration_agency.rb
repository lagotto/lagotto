class RegistrationAgency < ActiveRecord::Base
  has_many :works
  has_many :prefixes
  has_many :publishers

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  scope :order_by_name, -> { order("registration_agencies.title") }
  scope :is_doi_ra, -> { where(name: ["crossref", "datacite"]).order_by_name }

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
