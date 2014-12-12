class Publisher < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  has_many :users, primary_key: :crossref_id
  has_many :works, primary_key: :crossref_id
  has_many :publisher_options, primary_key: :crossref_id, :dependent => :destroy
  has_many :sources, :through => :publisher_options

  serialize :prefixes
  serialize :other_names

  validates :name, :presence => true
  validates :crossref_id, :presence => true, :uniqueness => true

  after_create :update_cache

  def to_param  # overridden, use crossref_id instead of id
    crossref_id
  end

  def work_count
    if ActionController::Base.perform_caching
      Rails.cache.read("publisher/#{crossref_id}/work_count/#{update_date}").to_i
    else
      works.size
    end
  end

  def work_count=(timestamp)
    Rails.cache.write("publisher/#{crossref_id}/work_count/#{timestamp}",
                      works.size)
  end

  def work_count_by_source(source_id)
    if ActionController::Base.perform_caching
      Rails.cache.read("publisher/#{crossref_id}/#{source_id}/work_count/#{update_date}").to_i
    else
      works.has_events.by_source(source_id).size
    end
  end

  def work_count_by_source=(source_id, timestamp)
    Rails.cache.write("publisher/#{crossref_id}/#{source_id}/work_count/#{timestamp}",
                      works.has_events.by_source(source_id).size)
  end

  def cache_key
    "publisher/#{crossref_id}/#{update_date}"
  end

  def update_date
    cached_at.utc.iso8601
  end

  def update_cache
    DelayedJob.delete_all(queue: "publisher-#{crossref_id}-cache")
    delay(priority: 1, queue: "publisher-#{crossref_id}-cache").write_cache
  end

  def write_cache
    # update cache_key as last step so that we have the old version until we are done
    now = Time.zone.now
    timestamp = now.utc.iso8601

    send("work_count=", timestamp)
    Source.visible.each { |source| send("work_count_by_source=", source.id, timestamp) }

    update_column(:cached_at, now)
  end
end
