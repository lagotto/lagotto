require 'cgi'
require "addressable/uri"

class Source < ActiveRecord::Base
  # include state machine
  include Statable

  # include default methods for subclasses
  include Configurable

  # include methods for calculating metrics
  include Measurable

  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include author methods
  include Authorable

  # include date methods
  include Dateable

  # include DOI helper methods
  include Resolvable

  # include summary counts
  include Countable

  # include Active Job helpers
  include Jobable

  # include hash helper
  include Hashie::Extensions::DeepFetch

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :works, :through => :retrieval_statuses
  has_many :publishers, :through => :publisher_options
  has_many :publisher_options
  has_many :alerts
  has_many :api_responses
  belongs_to :group

  serialize :config, OpenStruct

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true
  validates :priority, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :workers, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :timeout, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :wait_time, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :max_failed_queries, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :max_failed_query_time_interval, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :job_batch_size, :numericality => { :only_integer => true }, :inclusion => { :in => 1..1000, :message => "should be between 1 and 1000" }
  validates :rate_limiting, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_week, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_month, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_year, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_all, :numericality => { :only_integer => true, :greater_than => 0 }
  validate :validate_cron_line_format, if: Proc.new { |source| source.cron_line.present? }

  # filter sources by state
  scope :by_state, ->(state) { where("state = ?", state) }
  scope :by_states, ->(state) { where("state > ?", state) }
  scope :order_by_name, -> { order("group_id, sources.display_name") }

  scope :available, -> { by_state(0).order_by_name }
  scope :retired, -> { by_state(1).order_by_name }
  scope :inactive, -> { by_state(2).order_by_name }
  scope :disabled, -> { by_state(3).order_by_name }
  scope :waiting, -> { by_state(5).order_by_name }
  scope :working, -> { by_state(6).order_by_name }

  scope :installed, -> { by_states(0).order_by_name }
  scope :visible, -> { by_states(1).order_by_name }
  scope :active, -> { by_states(2).order_by_name }

  scope :for_events, -> { active.where("name != ?", 'relativemetric') }
  scope :queueable, -> { active.where("queueable = ?", true) }

  # some sources cannot be redistributed
  scope :public_sources, -> { where(private: false) }
  scope :private_sources, -> { where(private: true) }

  def to_param  # overridden, use name instead of id
    name
  end

  def remove_queues
    delete_jobs(name)
    retrieval_statuses.update_all(queued_at: nil)
  end

  def queue_all_works(options = {})
    return 0 unless active?

    # find works that need to be updated. Not queued currently, scheduled_at doesn't matter
    rs = retrieval_statuses

    # optionally limit to works scheduled_at in the past
    rs = rs.stale unless options[:all]

    # optionally limit by publication date
    if options[:start_date] && options[:end_date]
      rs = rs.joins(:work).where("works.published_on" => options[:start_date]..options[:end_date])
    end

    rs = rs.order("retrieval_statuses.id").pluck("retrieval_statuses.id")
    count = queue_work_jobs(rs, priority: priority)
  end

  def queue_work_jobs(rs, options = {})
    return 0 unless active?

    if rs.length == 0
      wait
      return 0
    end

    rs.each_slice(job_batch_size) do |rs_ids|
      RetrievalStatus.where("id in (?)", rs_ids).update_all(queued_at: Time.zone.now)
      SourceJob.set(queue: name, wait_until: schedule_at).perform_later(rs_ids, self)
    end

    rs.length
  end

  def schedule_at
    last_job = get_last_job(name)
    return Time.zone.now if last_job.nil?

    last_job + batch_interval
  end

  # condition for not adding more jobs and disabling the source
  def check_for_failures
    failed_queries = Alert.where("source_id = ? AND level > 1 AND updated_at > ?", id, Time.zone.now - max_failed_query_time_interval).count
    failed_queries > max_failed_queries
  end

  # limit the number of workers per source
  def check_for_available_workers
    workers >= worker_count
  end

  def check_for_active_workers
    worker_count > 1
  end

  def get_data(work, options={})
    query_url = get_query_url(work)
    if query_url.nil?
      result = {}
    else
      result = get_result(query_url, options.merge(request_options))

      # make sure we return a hash
      result = { 'data' => result } unless result.is_a?(Hash)
    end

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, work, options = {})
    # turn result into a hash for easier parsing later
    result = { 'data' => result } unless result.is_a?(Hash)

    # properly handle not found errors
    result = { 'data' => [] } if result[:status] == 404

    # return early if an error occured that is not a not_found error
    return result if result[:error]

    options.merge!(response_options)
    metrics = options[:metrics] || :citations

    events = get_events(result)
    events_url = events.length > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: get_events_by_day(events, work),
      events_by_month: get_events_by_month(events),
      events_url: events_url,
      event_count: events.length,
      event_metrics: get_event_metrics(metrics => events.length) }
  end

  def get_events_by_day(events, work)
    events = events.reject { |event| event[:event_time].nil? || Date.iso8601(event[:event_time]) - work.published_on > 30 }

    events.group_by { |event| event[:event_time][0..9] }.sort.map do |k, v|
      { year: k[0..3].to_i,
        month: k[5..6].to_i,
        day: k[8..9].to_i,
        total: v.length }
    end
  end

  def get_events_by_month(events)
    events = events.reject { |event| event[:event_time].nil? }

    events.group_by { |event| event[:event_time][0..6] }.sort.map do |k, v|
      { year: k[0..3].to_i,
        month: k[5..6].to_i,
        total: v.length }
    end
  end

  def request_options
    {}
  end

  def response_options
    {}
  end

  def get_query_url(work)
    if url.present? && work.doi.present?
      url % { doi: work.doi_escaped }
    end
  end

  def get_events_url(work)
    if events_url.present? && work.doi.present?
      events_url % { doi: work.doi_escaped }
    end
  end

  # fields with publisher-specific settings such as API keys,
  # i.e. everything that is not a URL
  def publisher_fields
    config_fields.select { |field| field !~ /url/ }
  end

  # all publisher-specific configurations
  def publisher_configs
    return [] unless by_publisher?

    publisher_options.pluck(:publisher_id, :config)
  end

  def publisher_config(publisher_id)
    conf = publisher_configs.find { |conf| conf[0] == publisher_id }
    conf.nil? ? OpenStruct.new : conf[1]
  end

  # all other fields
  def url_fields
    config_fields.select { |field| field =~ /url/ }
  end

  # Custom validations that are triggered in state machine
  def validate_config_fields
    config_fields.each do |field|

      # Some fields can be blank
      next if name == "crossref" && [:username, :password, :openurl_username].include?(field)
      next if name == "pmc" && [:journals, :username, :password].include?(field)
      next if name == "facebook" && [:client_id, :client_secret, :linkstat_url, :access_token].include?(field)
      next if name == "mendeley" && field == :access_token
      next if name == "twitter_search" && field == :access_token
      next if name == "scopus" && field == :insttoken

      errors.add(field, "can't be blank") if send(field).blank?
    end
  end

  # Custom validation for cron_line field
  def validate_cron_line_format
    cron_parser = CronParser.new(cron_line)
    cron_parser.next(Time.zone.now)
  rescue ArgumentError
    errors.add(:cron_line, "is not a valid crontab entry")
  end

  def cache_key
    "#{name}/#{update_date}"
  end

  def update_date
    cached_at.utc.iso8601
  end

  def update_cache
    CacheJob.perform_now(self)
  end

  def write_cache
    # update cache_key as last step so that we have the old version until we are done
    now = Time.zone.now
    timestamp = now.utc.iso8601

    # loop through cached attributes we want to update
    [:event_count,
     :work_count,
     :job_count,
     :queued_count,
     :stale_count,
     :response_count,
     :average_count,
     :maximum_count,
     :with_events_by_day_count,
     :without_events_by_day_count,
     :with_events_by_month_count,
     :without_events_by_month_count].each { |cached_attr| send("#{cached_attr}=", timestamp) }

    update_column(:cached_at, now)
  end

  # Remove all retrieval records for this source that have never been updated,
  # return true if all records are removed
  def remove_all_retrievals
    rs = retrieval_statuses.where(:retrieved_at == '1970-01-01').delete_all
    retrieval_statuses.count == 0
  end

  # Create an empty retrieval record for every work for the new source
  def create_retrievals
    work_ids = Work.pluck(:id)
    existing_ids = RetrievalStatus.where(:source_id => id).pluck(:work_id)

    (0...work_ids.length).step(1000) do |offset|
      ids = work_ids[offset...offset + 1000] & existing_ids
      InsertRetrievalJob.perform_later(self, ids)
     end
  end

  def insert_retrievals(ids = [])
    sql = "insert into retrieval_statuses (work_id, source_id, created_at, updated_at) select id, #{id}, now(), now() from works"
    sql += " where works.id not in (#{work_ids.join(',')})" unless ids.empty?
    ActiveRecord::Base.connection.execute sql
  end
end
