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
require 'ostruct'

class Source < ActiveRecord::Base

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :retrieval_histories, :dependent => :destroy
  has_many :articles, :through => :retrieval_statuses
  has_many :delayed_jobs, :primary_key => "name", :foreign_key => "queue"
  has_many :alerts
  has_many :api_responses
  belongs_to :group, :touch => true

  serialize :config, OpenStruct

  after_create :create_retrievals

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true
  validates :workers, :numericality => { :only_integer => true }, :inclusion => { :in => 1..10, :message => "should be between 1 and 10" }
  validates :timeout, :numericality => { :only_integer => true }, :inclusion => { :in => 1..3600, :message => "should be between 1 and 3600" }
  validates :wait_time, :numericality => { :only_integer => true }, :inclusion => { :in => 1..3600, :message => "should be between 1 and 3600" }
  validates :max_failed_queries, :numericality => { :only_integer => true }, :inclusion => { :in => 0..1000, :message => "should be between 0 and 1000" }
  validates :max_failed_query_time_interval, :numericality => { :only_integer => true }, :inclusion => { :in => 0..864000, :message => "should be between 0 and 864000" }
  validates :job_batch_size, :numericality => { :only_integer => true }, :inclusion => { :in => 1..1000, :message => "should be between 1 and 1000" }
  validates :max_job_batch_size, :numericality => { :only_integer => true }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }
  validates :batch_time_interval, :numericality => { :only_integer => true }, :inclusion => { :in => 1..86400, :message => "should be between 1 and 86400" }
  validates :staleness_week, :numericality => { :greater_than => 0 }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }
  validates :staleness_month, :numericality => { :greater_than => 0 }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }
  validates :staleness_year, :numericality => { :greater_than => 0 }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }
  validates :staleness_all, :numericality => { :greater_than => 0 }, :inclusion => { :in => 1..2678400, :message => "should be between 1 and 2678400" }

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

  scope :active, where(:active => true).order("group_id, display_name")
  scope :inactive, where(:active => false).order("group_id, display_name")
  scope :for_events, where("active = 1 AND name != 'relativemetric'").order("group_id, display_name")

  def to_param  # overridden, use name instead of id
    name
  end

  # some sources cannot be redistributed
  scope :public_sources, lambda { where("private = false") }
  scope :private_sources, lambda { where("private = true") }

  def get_data(article, options={})
    raise NotImplementedError, 'Children classes should override get_data method'
  end

  def queue_all_articles
    return 0 if inactive?

    rs = retrieval_statuses.pluck("retrieval_statuses.id")
    queue_article_jobs(rs)
  end

  def queue_articles
    return batch_time_interval unless active

    # check to see if there have been too many failures on trying to get data from the source
    # disable source if that is the case and return disable delay interval
    return disable_delay.seconds if check_for_failures

    # if there are jobs already queued, wait a little bit
    return wait_time if get_queued_job_count > 0

    # find articles that need to be updated. Not queued currently, scheduled_at in the past
    rs = retrieval_statuses.stale.limit(max_job_batch_size).pluck("retrieval_statuses.id")

    queue_article_jobs(rs)
    batch_time_interval
  end

  def queue_article_jobs(rs)
    logger.debug "#{name} total articles queued #{rs.length}"

    rs.each_slice(job_batch_size) do |rs_ids|
      Delayed::Job.enqueue SourceJob.new(rs_ids), queue: name
    end
    rs.length
  end

  def get_config_fields
    []
  end

  def get_queued_job_count
    Delayed::Job.count('id', :conditions => ["queue = ?", name])
  end

  def get_query_url(article)
    config.url % { :doi => article.doi_escaped }
  end

  def check_for_failures
    # condition for not adding more jobs and disabling the source

    failed_queries = Alert.where("source_id = :id and updated_at > :updated_date",
                                         { :id => id,
                                           :updated_date => (Time.zone.now - max_failed_query_time_interval.seconds) }).count(:id)

    if failed_queries > max_failed_queries
      Alert.create(:exception => "", :class_name => "TooManyErrorsBySourceError",
                          :message => "#{display_name} has exceeded maximum failed queries. Disabling the source.",
                          :source_id => id)
      self.update_attributes(disable_until: Time.zone.now + disable_delay.seconds)
    elsif disable_until.nil?
      false
    elsif disable_until < Time.zone.now
      self.update_attributes(disable_until: nil)
      false
    else
      true
    end
  end

  def job_batch_size
    config.job_batch_size || 200
  end

  def job_batch_size=(value)
    config.job_batch_size = value.to_i
  end

  def max_job_batch_size
    config.max_job_batch_size || 10000
  end

  def max_job_batch_size=(value)
    config.max_job_batch_size = value.to_i
  end

  def batch_time_interval
    config.batch_time_interval || 1.hour
  end

  def batch_time_interval=(value)
    config.batch_time_interval = value.to_i
  end

  def rate_limiting
    (max_job_batch_size.to_i * 3600 / batch_time_interval.to_i).round
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

  def disabled?
    disable_until && disable_until > Time.zone.now
  end

  def inactive?
    !active || disabled?
  end

  def status
    if inactive?
      "inactive"
    elsif disabled?
      "disabled"
    else
      "active"
    end
  end

  private

  def create_retrievals
    # Create an empty retrieval record for every article for the new source, make scheduled_at a random timestamp within a week
    conn = RetrievalStatus.connection
    random_time = Time.zone.now + rand(7.days)
    sql = "insert into retrieval_statuses (article_id, source_id, created_at, updated_at, scheduled_at) select id, #{id}, now(), now(), '#{random_time.to_formatted_s(:db)}' from articles"
    conn.execute sql
  end
end

module Exceptions
  # source is either not active or disabled
  class SourceInactiveError < StandardError; end

  # we have received too many errors (and will disable the source)
  class TooManyErrorsBySourceError < StandardError; end
end
