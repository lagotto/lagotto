class RelationType < ActiveRecord::Base
  has_many :reference_relations, dependent: :nullify
  has_many :version_relations, dependent: :nullify

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true, :uniqueness => true

  scope :referencable, -> { where(describes_reference: true) }
  scope :versionable, -> { where(describes_reference: false) }

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
