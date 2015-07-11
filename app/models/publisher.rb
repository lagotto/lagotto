class Publisher < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  has_many :users, primary_key: :member_id
  has_many :works, primary_key: :member_id
  has_many :publisher_options, primary_key: :member_id, :dependent => :destroy
  has_many :sources, :through => :publisher_options

  serialize :prefixes
  serialize :other_names

  validates :title, :presence => true
  validates :name, :member_id, :presence => true, :uniqueness => true

  after_create { |publisher| CacheJob.perform_later(publisher) }

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
      works.has_events.by_source(source_id).size
    end
  end

  def work_count_by_source=(source_id, time)
    Rails.cache.write("publisher/#{name}/#{source_id}/work_count/#{time}",
                      works.has_events.by_source(source_id).size)
  end

  def cache_key
    "publisher/#{name}-#{timestamp}"
  end

  def timestamp
    cached_at.utc.iso8601
  end

  def write_cache
    # update cache_key as last step so that we have the old version until we are done
    now = Time.zone.now

    send("work_count=", now.utc.iso8601)
    Source.visible.each { |source| send("work_count_by_source=", source.id, now.utc.iso8601) }

    update_column(:cached_at, now)
  end
end
