class Prefix < ActiveRecord::Base
  validates :prefix, uniqueness: true
end
