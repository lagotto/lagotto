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

  # include hash helper
  include Hashie::Extensions::DeepFetch

  BLANK_FIELDS = { "crossref" => [:username, :password, :openurl_username],
                   "pmc" => [:journals, :username, :password],
                   "facebook" => [:client_id, :client_secret, :url_linkstat, :access_token],
                   "mendeley" => [:access_token],
                   "twitter_search" => [:access_token],
                   "scopus" => [:insttoken] }

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :works, :through => :retrieval_statuses
  has_many :publishers, :through => :publisher_options
  has_many :publisher_options
  has_many :alerts
  has_many :api_responses
  has_many :relations
  belongs_to :group

  serialize :config, OpenStruct

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true
  validates :timeout, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :max_failed_queries, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :rate_limiting, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_week, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_month, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_year, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_all, :numericality => { :only_integer => true, :greater_than => 0 }
  validate :validate_cron_line_format, if: Proc.new { |source| source.cron_line.present? }

  # filter sources by state
  scope :by_state, ->(state) { where("state = ?", state) }
  scope :by_states, ->(state) { where("state > ?", state) }
  scope :order_by_title, -> { order("group_id, sources.title") }

  scope :available, -> { by_state(0).order_by_title }
  scope :retired, -> { by_state(1).order_by_title }
  scope :inactive, -> { by_state(2).order_by_title }
  scope :disabled, -> { by_state(3).order_by_title }
  scope :waiting, -> { by_state(5).order_by_title }
  scope :working, -> { by_state(6).order_by_title }

  scope :installed, -> { by_states(0).order_by_title }
  scope :visible, -> { by_states(1).order_by_title }
  scope :active, -> { by_states(2).order_by_title }

  scope :for_events, -> { active.where("name != ?", 'relativemetric') }
  scope :queueable, -> { active.where("queueable = ?", true) }
  scope :workable, -> { visible.where("workable = ?", true) }

  # some sources cannot be redistributed
  scope :public_sources, -> { where(private: false) }
  scope :private_sources, -> { where(private: true) }

  def to_param  # overridden, use name instead of id
    name
  end

  def remove_queues
    # delete_jobs(name)
    retrieval_statuses.update_all(queued_at: nil)
  end

  def queue_all_works(options = {})
    return 0 unless active?

    # find works that need to be updated.
    # Tracked, not queued currently, scheduled_at doesn't matter
    rs = retrieval_statuses.tracked

    # optionally limit to works scheduled_at in the past
    rs = rs.stale unless options[:all]

    # optionally limit by publication date
    if options[:start_date] && options[:end_date]
      rs = rs.joins(:work).where("works.published_on" => options[:start_date]..options[:end_date])
    end

    rs = rs.order("retrieval_statuses.id").pluck("retrieval_statuses.id")
    count = queue_work_jobs(rs)
  end

  def queue_work_jobs(rs, options = {})
    return 0 unless active?

    if rs.length == 0
      wait
      return 0
    end

    rs.each_slice(job_batch_size) do |rs_ids|
      RetrievalStatus.where("id in (?)", rs_ids).update_all(queued_at: Time.zone.now)
      SourceJob.set(queue: queue, wait_until: schedule_at).perform_later(rs_ids, self)
    end

    rs.length
  end

  def last_response
    @last_response ||= api_responses.maximum(:created_at) || Time.zone.now
  end

  def schedule_at
    last_response + batch_interval
  end

  # disable source if more than max_failed_queries (default: 200) in 24 hrs
  def check_for_failures
    failed_queries = Alert.where("source_id = ? AND level > 1 AND updated_at > ?", id, Time.zone.now - max_failed_query_time_interval).count
    failed_queries > max_failed_queries
  end

  # disable source if wait time at least 10 sec because of rate-limiting
  def check_for_rate_limits
    future_response_count < 360
  end

  # API responses last 60 min
  def current_response_count
    @current_response_count ||= api_responses.total(1).size
  end

  # expected API responses next 60 min, should be larger than zero
  def future_response_count
    @future_response_count ||= [rate_limiting * 2 - current_response_count, 0.001].sort.last
  end

  # calculate wait time until next API call
  def wait_time
    3600 / future_response_count
  end

  def get_data(work, options={})
    query_url = get_query_url(work)
    return query_url if query_url.is_a?(Hash)

    result = get_result(query_url, options.merge(request_options))

    # make sure we return a hash
    result = { 'data' => result } unless result.is_a?(Hash)

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

    related_works = get_related_works(result, work)
    extra = get_extra(result)
    events_url = related_works.length > 0 ? get_events_url(work) : nil

    options.merge!(response_options)
    options[:metrics] ||= :total
    metrics = get_metrics(options[:metrics] => related_works.length)

    { works: related_works,
      metrics: {
        source: name,
        work: work.pid,
        pdf: metrics[:pdf],
        html: metrics[:html],
        readers: metrics[:readers],
        comments: metrics[:comments],
        likes: metrics[:likes],
        total: metrics[:total],
        events_url: events_url,
        extra: extra,
        days: get_events_by_day(related_works, work),
        months: get_events_by_month(related_works) }.compact }
  end

  def get_events_by_day(events, work)
    events = events.reject { |event| event["timestamp"].nil? || Date.iso8601(event["timestamp"]) - work.published_on > 30 }

    events.group_by { |event| event["timestamp"][0..9] }.sort.map do |k, v|
      { year: k[0..3].to_i,
        month: k[5..6].to_i,
        day: k[8..9].to_i,
        total: v.length }
    end
  end

  def get_events_by_month(events)
    events = events.reject { |event| event["timestamp"].nil? }

    events.group_by { |event| event["timestamp"][0..6] }.sort.map do |k, v|
      { year: k[0..3].to_i,
        month: k[5..6].to_i,
        total: v.length }
    end
  end

  def get_extra(result)
    nil
  end

  def request_options
    {}
  end

  def response_options
    {}
  end

  def get_query_url(work, options = {})
    fail ArgumentError, "Source url is missing." if url.blank?

    query_string = get_query_string(work)
    return query_string if query_string.is_a?(Hash)

    url % { query_string: query_string }
  end

  def get_events_url(work)
    return nil unless has_attribute?(:events_url)
    fail ArgumentError, "Source events_url is missing." if events_url.blank?

    query_string = get_query_string(work)
    return query_string if query_string.is_a?(Hash)

    events_url % { query_string: query_string }
  end

  def get_query_string(work)
    return {} unless work.get_url || work.doi.present?

    [work.doi, work.canonical_url].compact.map { |i| "%22#{i}%22" }.join("+OR+")
  end

  # fields with urls, not user-configurable
  def url_fields
    config_fields.select { |field| field =~ /url\z/ }
  end

  # fields with publisher-specific settings such as API keys,
  # i.e. everything that is not a URL
  def publisher_fields
    config_fields.select { |field| field !~ /url/ }
  end

  # all other fields
  def other_fields
    config_fields.select { |field| field =~ /\Aurl.+/ }
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

  def allowed_blank_fields
    BLANK_FIELDS.fetch(name, [])
  end

  # Custom validations that are triggered in state machine
  def validate_config_fields
    config_fields.each do |field|

      # Some fields can be blank
      next if allowed_blank_fields.include?(field)
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
      Alert.where(message: message).where(unresolved: true).first_or_create(
        exception: "",
        class_name: "Faraday::ResourceNotFound",
        source_id: id,
        status: 404,
        level: Alert::FATAL)
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

  def cache_key
    "#{name}/#{update_date}"
  end

  def update_date
    cached_at.utc.iso8601
  end

  def update_cache
    CacheJob.perform_later(self)
  end

  def write_cache
    # update cache_key as last step so that we have the old version until we are done
    now = Time.zone.now
    timestamp = now.utc.iso8601

    # loop through cached attributes we want to update
    [:event_count,
     :work_count,
     :queued_count,
     :stale_count,
     :response_count,
     :average_count,
     :maximum_count,
     :with_events_by_day_count,
     :without_events_by_day_count,
     :with_events_by_month_count,
     :without_events_by_month_count].each { |cached_attr| send("#{cached_attr}=") }

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
