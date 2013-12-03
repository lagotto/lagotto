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

  after_create :create_retrievals
  after_update :expire_cache, :if => Proc.new { |source| source.name_changed? ||
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

  scope :active, where("state > 0").order("group_id, display_name")
  scope :inactive, where("state = 0").order("group_id, display_name")
  scope :for_events, where("state > 0 AND name != 'relativemetric'").order("group_id, display_name")
  scope :queueable, where("state > 0 AND queueable = 1").order("group_id, display_name")

  INTERVAL_OPTIONS = [['½ hour', 30.minutes],
                      ['1 hour', 1.hour],
                      ['2 hours', 2.hours],
                      ['3 hours', 3.hours],
                      ['6 hours', 6.hours],
                      ['12 hours', 12.hours],
                      ['24 hours', 24.hours],
                      ['¼ month', (1.month * 0.25).to_i],
                      ['½ month', (1.month * 0.5).to_i],
                      ['1 month', 1.month]]

  def self.validates_not_blank(*attrs)
    validates_each attrs do |record, attr, value|
      record.errors.add(attr, "can't be blank") if value.blank?
    end
  end

  state_machine :initial => :inactive do
    state :inactive, value: 0 # source disabled by admin
    state :disabled, value: 1 # can't queue or process jobs, generates alert
    state :idle, value: 2     # source active
    state :waiting, value: 3  # source active, waiting for next queueing job
    state :working, value: 4  # processing jobs
    state :queueing, value: 5 # queueing and processing jobs

    state all - [:inactive, :disabled] do
      def active?
        true
      end
    end

    state all - [:working, :queueing, :waiting, :idle] do
      def active?
        false
      end
    end

    after_transition any => :queueing do |source|
      source.add_queue
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

    event :activate do
      transition [:inactive] => :idle, :unless => :queueable
      transition [:inactive] => :queueing
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

  # some sources cannot be redistributed
  scope :public_sources, lambda { where("private = false") }
  scope :private_sources, lambda { where("private = true") }

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
    queue_article_jobs(rs, {})
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

  def get_config_fields
    []
  end

  def get_query_url(article)
    url % { :doi => article.doi_escaped }
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

  private

  private
  def create_retrievals
    # Create an empty retrieval record for every article for the new source, make scheduled_at a random timestamp within a week
    conn = RetrievalStatus.connection
    random_time = Time.zone.now + rand(7.days)
    sql = "insert into retrieval_statuses (article_id, source_id, created_at, updated_at, scheduled_at) select id, #{id}, now(), now(), '#{random_time.to_formatted_s(:db)}' from articles"
    conn.execute sql
  end

  def expire_cache
    return nil unless ActionController::Base.perform_caching

    url = "http://localhost/api/v3/sources/#{name}?api_key=#{APP_CONFIG['api_key']}"
    self.update_column(:cached_at, Time.zone.now) unless get_json(url).nil?

    status_url = "http://localhost/api/v3/status?api_key=#{APP_CONFIG['api_key']}"
    save_alm_data("status:timestamp", data: { timestamp: Time.zone.now.to_s(:number) }) unless get_json(status_url).nil?
  end
  handle_asynchronously :expire_cache, priority: 0, queue: "api-cache"
end

module Exceptions
  # source is either inactive or disabled
  class SourceInactiveError < StandardError; end

  # we have received too many errors (and will disable the source)
  class TooManyErrorsBySourceError < StandardError; end
end
