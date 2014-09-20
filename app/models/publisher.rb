class Publisher < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  has_many :users
  has_many :articles
  has_many :publisher_options, :dependent => :destroy
  has_many :sources, :through => :publisher_options

  serialize :prefixes
  serialize :other_names

  validates :name, :presence => true
  validates :crossref_id, :presence => true, :uniqueness => true

  def to_param  # overridden, use crossref_id instead of id
    crossref_id
  end

  def update_date
    updated_at.utc.iso8601
  end
end
