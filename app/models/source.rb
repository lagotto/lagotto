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
  has_one :job_queue, class_name: DelayedJob, primary_key: "queue", foreign_key: "queue", :dependent => :destroy
  belongs_to :group

  serialize :config, OpenStruct

  after_create :create_retrievals
  after_create :create_job_queue, :if => Proc.new{ self.queueable }

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
                      ['¼ month', 1.month * 0.25],
                      ['½ month', 1.month * 0.5],
                      ['1 month', 1.month]]

  def self.validates_not_blank(*attrs)
    validates_each attrs do |record, attr, value|
      record.errors.add(attr, "can't be blank") if value.blank?
    end
  end

  state_machine :initial => :inactive do
    state :inactive, value: 0 # source disabled by admin
    state :working, value: 1  # can't queue jobs but can process them
    state :queueing, value: 2 # can queue jobs and can process them
    state :disabled, value: 3 # can't queue or process jobs, generates alert
    state :waiting, value: 4  # can't queue or process jobs, next queueing job scheduled
    state :idle, value: 5 # can't queue or process jobs

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

    before_transition any => :queueing, :do => :start_queue
    before_transition :queueing => any - :queueing, :do => :stop_queue

    after_transition :to => :inactive do |source|
      source.update_attributes(run_at: Time.zone.now + 5.years)
    end

    after_transition :to => :disabled do |source|
      Alert.create(:exception => "", :class_name => "TooManyErrorsBySourceError",
                   :message => "#{source.display_name} has exceeded maximum failed queries. Disabling the source.",
                   :source_id => source.id)
      source.update_attributes(run_at: Time.zone.now + source.disable_delay)
    end

    after_transition :to => :waiting do |source|
      if source.check_for_queued_jobs
        source.update_attributes(run_at: Time.zone.now + source.wait_time)
      else
        source.update_attributes(run_at: source.run_at + source.batch_time_interval)
      end
    end

    after_transition :inactive => :working do |source|
      source.update_attributes(run_at: Time.zone.now)
    end

    event :activate do
      transition [:inactive] => :working
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

    event :check do
      transition any - [:disabled] => :disabled, :if => :check_for_failures
      transition any => :waiting, :if => :check_for_queued_jobs
      transition any => :queueing
    end

    event :work do
      transition [:idle, :waiting, :queueing] => :working
    end

    event :start_waiting do
      transition [:queueing, :working] => :waiting, :if => :queueable
      transition [:working] => :idle
    end
  end

  def to_param  # overridden, use name instead of id
    name
  end

  def get_data(article, options={})
    raise NotImplementedError, 'Children classes should override get_data method'
  end

  def start_queue
    # create queue job for this source if it doesn't exist already, schedule it for now
    # Some sources don't have a job queue, return false for them
    return false unless queueable

    self.update_attributes(queue: "#{name}-queue") if queue.nil?

    unless job_queue.nil?
      job_queue.update_attributes(run_at: Time.zone.now)
    else
      Delayed::Job.enqueue QueueJob.new(id), queue: "#{name}-queue", run_at: Time.zone.now, priority: 0
    end
  end

  def stop_queue
    job_queue.update_attributes(run_at: Time.zone.now + 5.years) unless job_queue.nil?
  end

  def queue_all_articles
    return 0 unless active?

    # find articles that are not queued currently, scheduled_at doesn't matter
    rs = retrieval_statuses.pluck("retrieval_statuses.id")
    count = queue_article_jobs(rs, { priority: 1 })

    # start working on jobs we have just queued
    work

    count
  end

  def queue_stale_articles
    # check to see if source is disabled, has too many failures or jobs are already queued
    check

    return 0 unless queueing?

    # find articles that need to be updated. Not queued currently, scheduled_at in the past
    rs = retrieval_statuses.stale.limit(max_job_batch_size).pluck("retrieval_statuses.id")
    count = queue_article_jobs(rs, {})

    # start working on jobs we have just queued
    work

    count
  end

  def queue_article_jobs(rs, options = {})
    return 0 unless active?

    schedule_at = DelayedJob.where(queue: name).maximum(:run_at) || Time.zone.now - batch_interval
    priority = options[:priority] || Delayed::Worker.default_priority

    rs.each_slice(job_batch_size) do |rs_ids|
      schedule_at += batch_interval
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
    failed_queries = Alert.where("source_id = ? and updated_at > ?", id, Time.zone.now - max_failed_query_time_interval).count(:id)
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
    config.timeout || 200
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

  def create_retrievals
    # Create an empty retrieval record for every article for the new source, make scheduled_at a random timestamp within a week
    conn = RetrievalStatus.connection
    random_time = Time.zone.now + rand(7.days)
    sql = "insert into retrieval_statuses (article_id, source_id, created_at, updated_at, scheduled_at) select id, #{id}, now(), now(), '#{random_time.to_formatted_s(:db)}' from articles"
    conn.execute sql
  end

  def create_job_queue
    # Create a delayed job for queueing articles
    DelayedJob.find_or_create_by_queue("#{name}-queue", run_at: Time.zone.now, priority: 0)
  end
end

module Exceptions
  # source is either inactive or disabled
  class SourceInactiveError < StandardError; end

  # we have received too many errors (and will disable the source)
  class TooManyErrorsBySourceError < StandardError; end
end
