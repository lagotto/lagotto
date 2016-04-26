class Prefix < ActiveRecord::Base
  belongs_to :registration_agency
  belongs_to :publisher

  validates :prefix, uniqueness: true
end
