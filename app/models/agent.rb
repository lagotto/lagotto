require 'cgi'
require "addressable/uri"

class Agent < ActiveRecord::Base
  # include state machine
  include Statable

  # include default methods for subclasses
  include Configurable

  # include methods for calculating metrics
  include Measurable

  # include HTTP request helpers
  include Networkable

  # include author methods
  include Authorable

  # include date methods
  include Dateable

  # include DOI helper methods
  include Resolvable

  # include helper module for extracting identifier
  include Identifiable

  # include summary counts
  include Countable

  # include helper module for query caching
  include Cacheable

  # include hash helper
  include Hashie::Extensions::DeepFetch

  # these fields can remain blank, validations will be skipped
  BLANK_FIELDS = { "crossref" => [:username, :password, :openurl_username],
                   "pmc" => [:journals, :username, :password],
                   "facebook" => [:client_id, :client_secret, :url_linkstat, :access_token],
                   "mendeley" => [:access_token],
                   "twitter_search" => [:access_token],
                   "scopus" => [:insttoken],
                   "crossref_import" => [:sample, :only_publishers],
                   "crossref_orcid" => [:sample, :only_publishers],
                   "crossref_publisher" => [:sample, :only_publishers],
                   "datacite_crossref" => [:only_publishers, :personal_access_token],
                   "datacite_datacentre" => [:only_publishers, :personal_access_token],
                   "datacite_import" => [:only_publishers, :personal_access_token],
                   "datacite_orcid" => [:only_publishers, :personal_access_token],
                   "datacite_github" => [:only_publishers],
                   "datacite_related" => [:only_publishers, :personal_access_token] }

  has_many :publishers, :through => :publisher_options
  has_many :publisher_options
  has_many :api_responses
  has_many :reference_relations
  has_many :version_relations
  belongs_to :group

  serialize :config, OpenStruct

  before_create :create_uuid

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true
  validates :timeout, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :max_failed_queries, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :rate_limiting, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :sample, :numericality => { :only_integer => true, :greater_than => 0 }, allow_blank: true
  validate :validate_cron_line_format

  # filter agents by state
  scope :by_state, ->(state) { where("state = ?", state) }
  scope :by_states, ->(state) { where("state > ?", state) }
  scope :order_by_title, -> { order("group_id, agents.title") }

  scope :available, -> { by_state(0).order_by_title }
  scope :retired, -> { by_state(1).order_by_title }
  scope :inactive, -> { by_state(2).order_by_title }
  scope :disabled, -> { by_state(3).order_by_title }
  scope :waiting, -> { by_state(5).order_by_title }
  scope :working, -> { by_state(6).order_by_title }

  scope :installed, -> { by_states(0).order_by_title }
  scope :visible, -> { by_states(1).order_by_title }
  scope :active, -> { by_states(2).order_by_title }
  scope :updating, -> { by_states(3).order_by_title }

  scope :for_events, -> { active.where("name != ?", 'relativemetric') }

  def to_param  # overridden, use name instead of id
    name
  end

  def remove_queues
    # delete_jobs(name)
  end

  def queue_jobs(options={})
    return 0 unless active?

    unless options[:all]
      return 0 unless stale?
    end

    # find works that we are tracking
    works = Work.tracked

    # optionally limit by publication date
    if options[:from_date] && options[:until_date]
      works = works.where(published_on: options[:from_date]..options[:until_date])
    end

    total = 0
    # pluck_in_batches is a custom method in config/initializers/active_record_extensions.rb
    works.pluck_in_batches(:id, batch_size: job_batch_size) do |ids|
      AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options.merge(ids: ids))
      total += ids.length
    end

    schedule_next_run if total > 0

    # return number of works queued
    total
  end

  # time the next batch should run
  def schedule_at
    last_response + batch_interval
  end

  # set time the agent should run again
  def schedule_next_run
    update_column(:run_at, CronParser.new(cron_line).next(Time.zone.now))
  end

  def stale?
    Time.zone.now > run_at
  end

  # disable agent if more than max_failed_queries (default: 200) in 24 hrs
  def check_for_failures
    failed_queries = Notification.where("source_id = ? AND level > 1 AND updated_at > ?", source_id, Time.zone.now - max_failed_query_time_interval).count
    failed_queries > max_failed_queries
  end

  # disable agent if rate_limiting reached
  def check_for_rate_limits
    rate_limit_remaining < 10
  end

  # calculate wait time until next API call
  # wait until reset time if rate-limiting limit is close
  def wait_time
    if rate_limit_remaining < 50
      [rate_limit_reset - Time.zone.now, 0.001].sort.last
    else
      3600.0 / rate_limiting
    end
  end

  def collect_data(options = {})
    data = get_data(options.merge(timeout: timeout, source_id: source_id))

    # if ENV["LOGSTASH_PATH"].present?
    #   # write API response from external agent to log/agent.log, using agent name and work pid as tags
    #   AGENT_LOGGER.tagged(name, pid) { AGENT_LOGGER.info "#{result.inspect}" }
    # end

    data = parse_data(data, options.merge(source_id: source_id))

    # push to deposit API if no error and we have collected works and/or events
    # returns hash with number of deposits created, e.g. { total: 10 }
    push_data(data, options)
  end

  def get_data(options={})
    query_url = get_query_url(options)
    return query_url.extend Hashie::Extensions::DeepFetch if query_url.is_a?(Hash)

    result = get_result(query_url, options.merge(request_options))

    # make sure we return a hash
    result = { 'data' => result } unless result.is_a?(Hash)

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, options = {})
    if !result.is_a?(Hash)
      # make sure we have a hash
      result = { 'data' => result }
      result.extend Hashie::Extensions::DeepFetch
    elsif result[:status] == 404
      # properly handle not found errors
      result = { 'data' => [] }
      result.extend Hashie::Extensions::DeepFetch
    elsif result[:error]
      # return early if an error occured that is not a not_found error
      return [result]
    end

    work = Work.where(id: options.fetch(:work_id, nil)).first

    get_relations_with_related_works(result, work)
  end

  def get_relations_with_related_works(result, work)
    []
  end

  def push_data(items, options={})
    deposits = Array(items).reduce([]) do |sum, item|
      begin
        relation = item.fetch(:relation, {})
        deposit = Deposit.create!(source_token: uuid,
                        message_type: item.fetch(:message_type, 'relation'),
                        prefix: item.fetch(:prefix, nil),
                        subj: item.fetch(:subj, nil),
                        obj: item.fetch(:obj, nil),
                        subj_id: relation.fetch('subj_id', nil),
                        obj_id: relation.fetch('obj_id', nil),
                        relation_type_id: relation.fetch('relation_type_id', nil),
                        source_id: relation.fetch('source_id', nil),
                        publisher_id: relation.fetch('publisher_id', nil),
                        registration_agency_id: relation.fetch('registration_agency_id', nil),
                        total: relation.fetch('total', nil),
                        occurred_at: relation.fetch('occurred_at', nil))
        sum << deposit
      rescue ActiveRecord::RecordInvalid => e
        Notification.create(exception: e, target_url: relation.fetch('subj_id', nil), source_id: source_id)
        sum
      end
    end

    { total: deposits.size }
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

  def get_extra(result)
    nil
  end

  def request_options
    {}
  end

  def response_options
    {}
  end

  def get_query_url(options = {})
    fail ArgumentError, "Agent url is missing." if url.blank?

    query_string = get_query_string(options)
    return query_string if query_string.is_a?(Hash)

    url % { query_string: query_string }
  end

  def get_provenance_url(options = {})
    fail ArgumentError, "Agent provenance_url is missing." if provenance_url.blank?

    query_string = get_query_string(options)
    return query_string if query_string.is_a?(Hash)

    provenance_url % { query_string: query_string }
  end

  def get_query_string(options = {})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && (work.get_url || work.doi.present?)

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
    config_fields.select { |field| field =~ /url.+/ }
  end

  # all publisher-specific configurations
  def publisher_configs
    return [] unless by_publisher?

    publisher_options.pluck(:publisher_id, :config)
  end

  def publisher_config(publisher_id)
    conf = publisher_configs.find { |c| c[0] == publisher_id }
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

  def timestamp
    cached_at.utc.iso8601
  end

  def cache_key
    "agent/#{name}-#{timestamp}"
  end

  def update_cache
    CacheJob.perform_later(self)
  end

  def write_cache
    # update cache_key as last step so that we have the old version until we are done
    now = Time.zone.now

    # loop through cached attributes we want to update
    [:response_count,
     :average_count,
     :maximum_count].each { |cached_attr| send("#{cached_attr}=", now.utc.iso8601) }

    update_column(:cached_at, now)
  end

  def create_uuid
    write_attribute(:uuid, SecureRandom.uuid)
  end
end
