class Source < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  scope :query, ->(query) { where("name like ? OR title like ?", "%#{query}%", "%#{query}%") }
  scope :order_by_name, -> { order("group_id, sources.title") }
  scope :for_results, -> { joins(:group).where("groups.name = ?", "results") }
  scope :for_relations, -> { joins(:group).where("groups.name = ?", "relations") }
  scope :for_results_and_relations, -> { joins(:group).where("groups.name IN (?)", ["results", "relations"]) }
  scope :for_contributions, -> { joins(:group).where("groups.name = ?", "contributions") }
  scope :for_publishers, -> { joins(:group).where("groups.name = ?", "publishers") }

  # some sources cannot be redistributed
  scope :public_sources, -> { where(private: false) }
  scope :private_sources, -> { where(private: true) }
  scope :accessible, ->(role) { where("private <= ?", role) }

  def to_param  # overridden, use name instead of id
    name
  end
end
