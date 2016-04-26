class Publisher < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include helper module for query caching
  include Cacheable

  has_many :users
  has_many :works
  has_many :prefixes
  has_many :publisher_options
  has_many :sources, :through => :publisher_options
  has_many :relations
  has_many :contributions
  belongs_to :registration_agency

  serialize :other_names

  validates :title, :presence => true
  validates :name, :presence => true, :uniqueness => true

  after_commit :update_cache, :on => :create

  scope :order_by_name, -> { order("publishers.title") }
  scope :active, -> { where(active: true).order_by_name }
  scope :inactive, -> { where(active: false).order_by_name }
  scope :query, ->(query) { where("title like ?", "%#{query}%") }

  def to_param  # overridden, use name instead of id
    name
  end

  def work_count
    if ActionController::Base.perform_caching
      Rails.cache.read("publisher/#{name}/work_count/#{timestamp}").to_i
    else
      works.size
    end
  end

  def work_count=(time)
    Rails.cache.write("publisher/#{name}/work_count/#{time}",
                      works.size)
  end

  def work_count_by_source(source_id)
    if ActionController::Base.perform_caching
      Rails.cache.read("publisher/#{name}/#{source_id}/work_count/#{timestamp}").to_i
    else
      works.has_results.by_source(source_id).size
    end
  end

  def work_count_by_source=(source_id, time)
    Rails.cache.write("publisher/#{name}/#{source_id}/work_count/#{time}",
                      works.has_results.by_source(source_id).size)
  end

  def cache_key
    "publisher/#{name}-#{timestamp}"
  end

  def timestamp
    cached_at.utc.iso8601
  end

  def update_cache
    CacheJob.perform_later(self)
  end

  def write_cache
    # update cache_key as last step so that we have the old version until we are done
    now = Time.zone.now

    send("work_count=", now.utc.iso8601)
    Source.active.each { |source| send("work_count_by_source=", source.id, now.utc.iso8601) }

    update_column(:cached_at, now)
  end
end
