class Source < ActiveRecord::Base
  # include methods for calculating metrics
  include Measurable

  # include CouchDB helpers
  include Couchable

  # include date methods concern
  include Dateable

  # include summary counts
  include Countable

  # include hash helper
  include Hashie::Extensions::DeepFetch

  has_many :traces, :dependent => :destroy
  has_many :works, :through => :traces
  has_many :deposits, :dependent => :destroy
  has_many :notifications
  belongs_to :group

  serialize :config, OpenStruct

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  scope :order_by_name, -> { order("group_id, sources.title") }
  scope :active, -> { where(active: true).order_by_name }

  # some sources cannot be redistributed
  scope :public_sources, -> { where(private: false) }
  scope :private_sources, -> { where(private: true) }

  def to_param  # overridden, use name instead of id
    name
  end

  def display_name
    title
  end

  def status
    (active ? "active" : "inactive")
  end

  def timestamp
    cached_at.utc.iso8601
  end

  def cache_key
    "source/#{name}-#{timestamp}"
  end

  def update_cache
    CacheJob.perform_later(self)
  end

  def write_cache
    # update cache_key as last step so that we have the old version until we are done
    now = Time.zone.now

    # loop through cached attributes we want to update
    [:event_count,
     :work_count,
     :queued_count,
     :stale_count,
     :refreshed_count,
     :response_count,
     :average_count,
     :maximum_count,
     :with_events_by_day_count,
     :without_events_by_day_count,
     :not_updated_by_day_count,
     :with_events_by_month_count,
     :without_events_by_month_count,
     :not_updated_by_month_count].each { |cached_attr| send("#{cached_attr}=", now.utc.iso8601) }

    update_column(:cached_at, now)
  end

  # Remove all retrieval records for this source that have never been updated,
  # return true if all records are removed
  def remove_all_events
    rs = events.where(:retrieved_at == '1970-01-01').delete_all
    events.count == 0
  end

  # Create an empty event record for every work for the new source
  def create_events
    work_ids = Work.pluck(:id)
    existing_ids = Event.where(:source_id => id).pluck(:work_id)

    (0...work_ids.length).step(1000) do |offset|
      ids = work_ids[offset...offset + 1000] & existing_ids
      InsertRetrievalJob.perform_later(self, ids)
     end
  end

  def insert_events(ids = [])
    sql = "insert into events (work_id, source_id, created_at, updated_at) select id, #{id}, now(), now() from works"
    sql += " where works.id not in (#{work_ids.join(',')})" unless ids.empty?
    ActiveRecord::Base.connection.execute sql
  end
end
