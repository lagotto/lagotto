class Source < ActiveRecord::Base
  # include methods for calculating metrics
  include Measurable

  # include date methods concern
  include Dateable

  # include hash helper
  include Hashie::Extensions::DeepFetch

  serialize :config, OpenStruct

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  scope :query, ->(query) { where("name like ? OR title like ?", "%#{query}%", "%#{query}%") }
  scope :order_by_name, -> { order("group_id, sources.title") }
  scope :active, -> { where(active: true).order_by_name }
  scope :for_results, -> { active.joins(:group).where("groups.name = ?", "results") }
  scope :for_relations, -> { active.joins(:group).where("groups.name = ?", "relations") }
  scope :for_results_and_relations, -> { active.joins(:group).where("groups.name IN (?)", ["results", "relations"]) }
  scope :for_contributions, -> { active.joins(:group).where("groups.name = ?", "contributions") }
  scope :for_publishers, -> { active.joins(:group).where("groups.name = ?", "publishers") }

  # some sources cannot be redistributed
  scope :public_sources, -> { where(private: false) }
  scope :private_sources, -> { where(private: true) }
  scope :accessible, ->(role) { where("private <= ?", role) }

  def to_param  # overridden, use name instead of id
    name
  end

  def display_name
    title
  end

  def human_state_name
    (active ? "active" : "inactive")
  end

  def get_results_by_month(results, options={})
    results = results.reject { |relation| relation["occurred_at"].nil? }

    options[:metrics] ||= :total
    results.group_by { |relation| relation["occurred_at"][0..6] }.sort.map do |k, v|
      { year: k[0..3].to_i,
        month: k[5..6].to_i,
        options[:metrics] => v.length,
        total: v.length }
    end
  end

  def timestamp
    cached_at.utc.iso8601
  end
end
