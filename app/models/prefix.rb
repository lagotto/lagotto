class Prefix < ActiveRecord::Base
  # include helper module for query caching
  include Cacheable

  belongs_to :registration_agency
  belongs_to :publisher

  validates :name, uniqueness: true

  def timestamp
    updated_at.utc.iso8601
  end
end
