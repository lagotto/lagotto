class Group < ActiveRecord::Base
  has_many :sources, -> { order(:display_name) }, :dependent => :nullify

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true

  scope :visible, -> { joins(:sources).where("state > ?", 1).order("groups.id") }
  scope :with_sources, -> { joins(:sources).order("groups.id") }
end
