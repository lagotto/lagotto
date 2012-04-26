class Group < ActiveRecord::Base
  has_many :sources, :dependent => :nullify

  validates_presence_of :name
end
