class Source < ActiveRecord::Base
  # include methods for calculating metrics
  include Measurable

  # include date methods concern
  include Dateable

  # include summary counts
  include Countable

  # include hash helper
  include Hashie::Extensions::DeepFetch

  has_many :events, :dependent => :destroy
  has_many :relations, :dependent => :destroy
  has_many :months
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

  def human_state_name
    (active ? "active" : "inactive")
  end

  def get_events_by_month(events, options={})
    events = events.reject { |event| event["timestamp"].nil? }

    options[:metrics] ||= :total
    events.group_by { |event| event["timestamp"][0..6] }.sort.map do |k, v|
      { year: k[0..3].to_i,
        month: k[5..6].to_i,
        options[:metrics] => v.length,
        total: v.length }
    end
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

  # import couchdb data for lagotto 4.0 upgrade
  def import_from_couchdb
    return 0 unless active?

    # find works that need to be imported.
    ids = events.order("events.id").pluck("events.id")
    count = queue_import_jobs(ids)
  end

  def queue_import_jobs(ids, options = {})
    return 0 unless active?

    if ids.length == 0
      wait
      return 0
    end

    ids.each_slice(job_batch_size) do |_ids|
      CouchdbImportJob.perform_later(_ids)
    end

    ids.length
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
     :relation_count,
     :with_events_by_day_count,
     :without_events_by_day_count,
     :not_updated_by_day_count,
     :with_events_by_month_count,
     :without_events_by_month_count,
     :not_updated_by_month_count].each { |cached_attr| send("#{cached_attr}=", now.utc.iso8601) }

    update_column(:cached_at, now)
  end
end
