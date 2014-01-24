# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'cgi'

class Source < ActiveRecord::Base

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :retrieval_histories, :dependent => :destroy
  has_many :articles, :through => :retrieval_statuses
  has_many :alerts
  has_many :api_responses
  has_many :delayed_jobs, primary_key: "name", foreign_key: "queue", :dependent => :destroy
  belongs_to :group

  serialize :config, OpenStruct

  after_update :check_cache, :if => Proc.new { |source| source.name_changed? ||
                                                        source.display_name_changed? ||
                                                        source.state_changed? ||
                                                        source.group_id_changed? }

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true
  validates :workers, :numericality => { :only_integer => true }, :inclusion => { :in => 1..10, :message => "should be between 1 and 10" }
  validates :timeout, :numericality => { :only_integer => true }, :inclusion => { :in => 1..3600, :message => "should be between 1 and 3600" }
  validates :wait_time, :numericality => { :only_integer => true }, :inclusion => { :in => 1..3600, :message => "should be between 1 and 3600" }
  validates :max_failed_queries, :numericality => { :only_integer => true }, :inclusion => { :in => 1..1000, :message => "should be between 1 and 1000" }
  validates :max_failed_query_time_interval, :numericality => { :only_integer => true }, :inclusion => { :in => 1..864000, :message => "should be between 1 and 864000" }
  validates :job_batch_size, :numericality => { :only_integer => true }, :inclusion => { :in => 1..1000, :message => "should be between 1 and 1000" }
  validates :rate_limiting, :numericality => { :only_integer => true }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }
  validates :batch_time_interval, :numericality => { :only_integer => true }, :inclusion => { :in => 1..86400, :message => "should be between 1 and 86400" }
  validates :staleness_week, :numericality => { :greater_than => 0 }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }
  validates :staleness_month, :numericality => { :greater_than => 0 }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }
  validates :staleness_year, :numericality => { :greater_than => 0 }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }
  validates :staleness_all, :numericality => { :greater_than => 0 }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }

  scope :available, where("state = 0").order("group_id, sources.display_name")
  scope :installed, where("state > 0").order("group_id, sources.display_name")
  scope :retired, where("state = 1").order("group_id, sources.display_name")
  scope :inactive, where("state = 2").order("group_id, sources.display_name")
  scope :active, where("state > 2").order("group_id, sources.display_name")
  scope :for_events, where("state > 2 AND name != 'relativemetric'").order("group_id, sources.display_name")
  scope :queueable, where("state > 2 AND queueable = 1").order("group_id, sources.display_name")

  # some sources cannot be redistributed
  scope :public_sources, lambda { where("private = false") }
  scope :private_sources, lambda { where("private = true") }

  INTERVAL_OPTIONS = [['½ hour', 30.minutes],
                      ['1 hour', 1.hour],
                      ['2 hours', 2.hours],
                      ['3 hours', 3.hours],
                      ['6 hours', 6.hours],
                      ['12 hours', 12.hours],
                      ['24 hours', 24.hours],
                      ['¼ month', (1.month * 0.25).to_i],
                      ['½ month', (1.month * 0.5).to_i],
                      ['1 month', 1.month],
                      ['3 months', 3.months],
                      ['6 months', 6.months],
                      ['12 months', 12.months]]

  state_machine :initial => :available do
    state :available, value: 0 # source available, but not installed
    state :retired, value: 1   # source installed, but no longer accepting new data
    state :inactive, value: 2  # source disabled by admin
    state :disabled, value: 3  # can't queue or process jobs, generates alert
    state :idle, value: 4      # source active
    state :waiting, value: 5   # source active, waiting for next queueing job
    state :working, value: 6   # processing jobs
    state :queueing, value: 7  # queueing and processing jobs

    state all - [:available, :retired, :inactive, :disabled] do
      def active?
        true
      end
    end

    state all - [:working, :queueing, :waiting, :idle] do
      def active?
        false
      end
    end

    state all - [:available, :retired, :inactive] do
      validate { |source| source.validate_config_fields }
    end

    state all - [:available] do
      def installed?
        true
      end
    end

    state :available do
      def installed?
        false
      end
    end

    after_transition any => :queueing do |source|
      source.add_queue
    end

    after_transition :available => any - [:available, :retired] do |source|
      source.create_retrievals
    end

    after_transition :to => :inactive do |source|
      source.remove_queues
      source.update_attributes(run_at: Time.zone.now + 5.years)
    end

    after_transition :inactive => [:queueing, :idle] do |source|
      source.update_attributes(run_at: Time.zone.now)
    end

    after_transition any - [:disabled] => :disabled do |source|
      Alert.create(:exception => "", :class_name => "TooManyErrorsBySourceError",
                   :message => "#{source.display_name} has exceeded maximum failed queries. Disabling the source.",
                   :source_id => source.id)
      source.add_queue(Time.zone.now + source.disable_delay)
      report = Report.find_or_create_by_name(:name => "Disabled Source Report")
      report.send_disabled_source_report(source.id)
    end

    after_transition :to => :waiting do |source|
      source.add_queue(Time.zone.now + source.wait_time) if source.check_for_queued_jobs
    end

    event :install do
      transition [:available] => :retired, :if => :obsolete?
      transition [:available] => :inactive
    end

    event :uninstall do
      transition any - [:available] => :available, :if => :remove_all_retrievals
      transition any - [:available, :retired] => :retired
    end

    event :activate do
      transition [:available] => :retired, :if => :obsolete?
      transition [:available, :inactive] => :idle, :unless => :queueable
      transition [:available, :inactive] => :queueing
      transition any => same
    end

    event :inactivate do
      transition any => :inactive
    end

    event :disable do
      transition any => :disabled
    end

    event :start_queueing do
      transition [:working, :waiting] => :queueing, :if => :queueable
    end

    event :stop_queueing do
      transition any - [:waiting, :inactive, :disabled] => :waiting, :if => :queueable
      transition any => same
    end

    event :start_jobs_with_check do
      transition any => :disabled, :if => :check_for_failures
      transition any => :working
    end

    event :start_working_with_check do
      transition [:inactive] => same
      transition any => :disabled, :if => :check_for_failures
      transition any => :waiting, :if => :check_for_queued_jobs
      transition any => :working
    end

    event :start_working do
      transition [:idle, :waiting, :queueing] => :working
      transition any => same
    end

    event :stop_working do
      transition [:queueing, :working] => :waiting, :if => :queueable
      transition [:working] => :idle
    end

    event :start_waiting do
      transition any => :waiting, :if => :queueable
      transition any => :idle
    end
  end

  def to_param  # overridden, use name instead of id
    name
  end

  def get_data(article, options={})
    raise NotImplementedError, 'Children classes should override get_data method'
  end

  def add_queue(queue_at = Time.zone.now)
    # create queue job for this source if it doesn't exist already
    # Some sources can't have a job queue, return false for them
    # Only create queue if delayed_job is enabled, i.e. not in testing
    return false unless queueable

    if Delayed::Worker.delay_jobs
      DelayedJob.delete_all(queue: "#{name}-queue")
      Delayed::Job.enqueue QueueJob.new(id), queue: "#{name}-queue", run_at: queue_at, priority: 1
    end

    self.update_attributes(run_at: queue_at)
  end

  def get_queue
    DelayedJob.where(queue: "#{name}-queue").first
  end

  def remove_queues
    DelayedJob.delete_all(queue: "#{name}-queue")
    DelayedJob.delete_all(queue: name)
    RetrievalStatus.update_all(["queued_at = ?", nil], ["source_id = ?", id])
  end

  def queue_all_articles
    start_working

    return 0 unless working?

    # find articles that are not queued currently, scheduled_at doesn't matter
    rs = retrieval_statuses.pluck("retrieval_statuses.id")
    queue_article_jobs(rs, { priority: 2 })
  end

  def queue_stale_articles
    # check to see if source is disabled, has too many failures or jobs are already queued
    start_working_with_check

    return 0 unless working?

    # find articles that need to be updated. Not queued currently, scheduled_at in the past
    rs = retrieval_statuses.stale.limit(max_job_batch_size).pluck("retrieval_statuses.id")
    queue_article_jobs(rs)
  end

  def queue_article_jobs(rs, options = {})
    return 0 unless active?

    if rs.length == 0
      stop_working
      return 0
    end

    priority = options[:priority] || Delayed::Worker.default_priority

    rs.each_slice(job_batch_size) do |rs_ids|
      Delayed::Job.enqueue SourceJob.new(rs_ids, id), queue: name, run_at: schedule_at, priority: priority
    end

    rs.length
  end

  # Array of hashes for forms, defined in subclassed sources
  def get_config_fields
    []
  end

  # List of field names for strong_parameters and validations
  def config_fields
    get_config_fields.map { |f| f[:field_name].to_sym }
  end

  # Custom validations that are triggered in state machine
  def validate_config_fields
    config_fields.each do |field|
      errors.add(field, "can't be blank") if send(field).blank?
    end
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

  def events_url
    config.events_url
  end

  def events_url=(value)
    config.events_url = value
  end

  def username
    config.username
  end

  def username=(value)
    config.username = value
  end

  def password
    config.password
  end

  def password=(value)
    config.password = value
  end

  def api_key
    config.api_key
  end

  def api_key=(value)
    config.api_key = value
  end

  def access_token
    config.access_token
  end

  def access_token=(value)
    config.access_token = value
  end

  def get_query_url(article)
    url % { :doi => article.doi_escaped }
  end

  def get_events_url(article)
    events_url % { :doi => article.doi_escaped }
  end

  def check_for_failures
    # condition for not adding more jobs and disabling the source
    failed_queries = Alert.where("source_id = ? and updated_at > ?", id, Time.zone.now - max_failed_query_time_interval).count
    failed_queries > max_failed_queries
  end

  def check_for_queued_jobs
    get_queued_job_count > 0
  end

  def get_queued_job_count
    Delayed::Job.count('id', :conditions => ["queue = ?", name])
  end

  def get_queueing_job_count
    Delayed::Job.count('id', :conditions => ["queue = ?", "#{name}-queue"])
  end

  def schedule_at
    last_job = DelayedJob.where(queue: name).maximum(:run_at)
    return Time.zone.now if last_job.nil?

    last_job + batch_interval
  end

  def workers
    config.workers || 1
  end

  def workers=(value)
    config.workers = value.to_i
  end

  def disable_delay
    config.disable_delay || 10
  end

  def disable_delay=(value)
    config.disable_delay = value.to_i
  end

  def timeout
    config.timeout || 30
  end

  def timeout=(value)
    config.timeout = value.to_i
  end

  def wait_time
    config.wait_time || 300
  end

  def wait_time=(value)
    config.wait_time = value.to_i
  end

  def max_failed_queries
    config.max_failed_queries || 200
  end

  def max_failed_queries=(value)
    config.max_failed_queries = value.to_i
  end

  def max_failed_query_time_interval
    config.max_failed_query_time_interval || 86400
  end

  def max_failed_query_time_interval=(value)
    config.max_failed_query_time_interval = value.to_i
  end

  def job_batch_size
    config.job_batch_size || 200
  end

  def job_batch_size=(value)
    config.job_batch_size = value.to_i
  end

  def max_job_batch_size
    (rate_limiting * batch_time_interval / 3600).round
  end

  def rate_limiting
    config.rate_limiting || 10000
  end

  def rate_limiting=(value)
    config.rate_limiting = value.to_i
  end

  def job_interval
    3600 / rate_limiting
  end

  def batch_interval
    job_interval * job_batch_size
  end

  def batch_time_interval
    config.batch_time_interval || 1.hour
  end

  def batch_time_interval=(value)
    config.batch_time_interval = value.to_i
  end

  # The update interval for articles depends on article age. We use 4 different intervals that have default settings, but can also be configured individually per source:
  # * first week: update daily
  # * first month: update daily
  # * first year: update every ¼ month
  # * after one year: update monthly
  def staleness_week
    config.staleness_week || 1.day
  end

  def staleness_week=(value)
    config.staleness_week = value.to_i
  end

  def staleness_month
    config.staleness_month || 1.day
  end

  def staleness_month=(value)
    config.staleness_month = value.to_i
  end

  def staleness_year
    config.staleness_year || (1.month * 0.25).to_i
  end

  def staleness_year=(value)
    config.staleness_year = value.to_i
  end

  def staleness_all
    config.staleness_all || 1.month
  end

  def staleness_all=(value)
    config.staleness_all = value.to_i
  end

  def staleness
    [staleness_week, staleness_month, staleness_year, staleness_all]
  end

  def staleness_with_limits
    ["in the last 7 days", "in the last 31 days", "in the last year", "more than a year ago"].zip(staleness)
  end

  # is this source no longer accepting new data?
  def obsolete
    config.obsolete || false
  end

  def obsolete=(value)
    config.obsolete = value
  end

  alias_method :obsolete?, :obsolete

  def check_cache
    self.delay(priority: 3, queue: "api-cache").expire_cache if ActionController::Base.perform_caching
  end

  def remove_all_retrievals
    # Remove all retrieval records for this source that have never been updated,
    # return true if all records are removed
    rs = retrieval_statuses.where(:retrieved_at == '1970-01-01').delete_all
    retrieval_statuses.count == 0
  end

  def create_retrievals
    # Create an empty retrieval record for every article for the new source
    article_ids = RetrievalStatus.where(:source_id => id).pluck(:article_id)
    conn = RetrievalStatus.connection
    if article_ids.empty?
      sql = "insert into retrieval_statuses (article_id, source_id, created_at, updated_at, scheduled_at) select id, #{id}, now(), now(), now() from articles"
    else
      sql = "insert into retrieval_statuses (article_id, source_id, created_at, updated_at, scheduled_at) select id, #{id}, now(), now(), now() from articles where articles.id not in (#{article_ids.join(",")})"
    end
    conn.execute sql
  end

  private

  def expire_cache
    self.update_column(:cached_at, Time.zone.now)
    source_url = "http://localhost/api/v3/sources/#{name}?api_key=#{CONFIG[:api_key]}"
    get_json(source_url)

    Rails.cache.write('status:timestamp', Time.zone.now.utc.iso8601)
    status_url = "http://localhost/api/v3/status?api_key=#{CONFIG[:api_key]}"
    get_json(status_url)
  end
end

module Exceptions
  # source is either inactive or disabled
  class SourceInactiveError < StandardError; end

  # we have received too many errors (and will disable the source)
  class TooManyErrorsBySourceError < StandardError; end
end
