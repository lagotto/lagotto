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

  has_many :events, :dependent => :destroy
  has_many :works, :through => :events
  belongs_to :group

  serialize :config, OpenStruct

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  scope :order_by_name, -> { order("group_id, sources.title") }
  scope :active, -> { where(active: true).order_by_name }
  scope :eventable, -> { active.where(eventable: true) }

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

  def state
    (active ? "active" : "inactive")
  end

  # Format events for all works as csv
  # Show historical data if options[:format] is used
  # options[:format] can be "html", "pdf" or "combined"
  # options[:month] and options[:year] are the starting month and year, default to last month
  def to_csv(options = {})
    if ["html", "pdf", "xml", "combined"].include? options[:format]
      view = "#{options[:name]}_#{options[:format]}_views"
    else
      view = options[:name]
    end

    service_url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/#{view}"

    result = get_result(service_url, options.merge(timeout: 1800))
    if result.blank? || result["rows"].blank?
      message = "CouchDB report for #{options[:name]} could not be retrieved."
      Notification.where(message: message).where(unresolved: true).first_or_create(
        exception: "",
        class_name: "Faraday::ResourceNotFound",
        source_id: id,
        status: 404,
        level: Notification::FATAL)
      return ""
    end

    if view == options[:name]
      CSV.generate do |csv|
        csv << ["pid_type", "pid", "html", "pdf", "total"]
        result["rows"].each { |row| csv << ["doi", row["key"], row["value"]["html"], row["value"]["pdf"], row["value"]["total"]] }
      end
    else
      dates = date_range(options).map { |date| "#{date[:year]}-#{date[:month]}" }

      CSV.generate do |csv|
        csv << ["pid_type", "pid"] + dates
        result["rows"].each { |row| csv << ["doi", row["key"]] + dates.map { |date| row["value"][date] || 0 } }
      end
    end
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
     :work_count].each { |cached_attr| send("#{cached_attr}=", now.utc.iso8601) }

    update_column(:cached_at, now)
  end

  # Remove all event records for this source that have never been updated,
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
      InsertEventJob.perform_later(self, ids)
     end
  end

  def insert_events(ids = [])
    sql = "insert into events (work_id, source_id, created_at, updated_at) select id, #{id}, now(), now() from works"
    sql += " where works.id not in (#{work_ids.join(',')})" unless ids.empty?
    ActiveRecord::Base.connection.execute sql
  end
end
