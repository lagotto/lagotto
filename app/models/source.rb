# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
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

  # include date methods concern
  include Dateable

  # include hash helper
  include Hashie::Extensions::DeepFetch

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :articles, :through => :retrieval_statuses
  has_many :alerts
  has_many :api_responses
  has_many :delayed_jobs, primary_key: "name", foreign_key: "queue", :dependent => :destroy
  belongs_to :group

  serialize :config, OpenStruct

  after_update :check_cache, :if => proc { |source| source.state_changed? || source.display_name_changed? }

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true
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
  validate :validate_cron_line_format, :allow_blank => true

  scope :available, where("state = ?", 0).order("group_id, sources.display_name")
  scope :installed, where("state > ?", 0).order("group_id, sources.display_name")
  scope :retired, where("state = ?", 1).order("group_id, sources.display_name")
  scope :visible, where("state > ?", 1).order("group_id, sources.display_name")
  scope :inactive, where("state = ?", 2).order("group_id, sources.display_name")
  scope :active, where("state > ?", 2).order("group_id, sources.display_name")
  scope :for_events, where("state > ?", 2).where("name != ?", 'relativemetric').order("group_id, sources.display_name")
  scope :queueable, where("state > ?", 2).where("queueable = ?", true).order("group_id, sources.display_name")

  # some sources cannot be redistributed
  scope :public_sources, lambda { where("private = ?", false) }
  scope :private_sources, lambda { where("private = ?", true) }

  def to_param  # overridden, use name instead of id
    name
  end

  def remove_queues
    delayed_jobs.delete_all
    retrieval_statuses.update_all(["queued_at = ?", nil])
  end

  def queue_all_articles(options = {})
    return 0 unless active?

    priority = options[:priority] || Delayed::Worker.default_priority

    # find articles that need to be updated. Not queued currently, scheduled_at doesn't matter
    rs = retrieval_statuses

    # optionally limit to articles scheduled_at in the past
    rs = rs.stale unless options[:all]

    # optionally limit by publication date
    if options[:start_date] && options[:end_date]
      rs = rs.joins(:article).where("articles.published_on" => options[:start_date]..options[:end_date])
    end

    rs = rs.order("retrieval_statuses.id").pluck("retrieval_statuses.id")
    count = queue_article_jobs(rs, priority: priority)
  end

  def queue_article_jobs(rs, options = {})
    return 0 unless active?

    if rs.length == 0
      wait
      return 0
    end

    priority = options[:priority] || Delayed::Worker.default_priority

    rs.each_slice(job_batch_size) do |rs_ids|
      Delayed::Job.enqueue SourceJob.new(rs_ids, id), queue: name, run_at: schedule_at, priority: priority
    end

    rs.length
  end

  def schedule_at
    last_job = DelayedJob.where(queue: name).maximum(:run_at)
    return Time.zone.now if last_job.nil?

    last_job + batch_interval
  end

  # condition for not adding more jobs and disabling the source
  def check_for_failures
    failed_queries = Alert.where("source_id = ? and updated_at > ?", id, Time.zone.now - max_failed_query_time_interval).count
    failed_queries > max_failed_queries
  end

  # limit the number of workers per source
  def check_for_available_workers
    workers >= working_count
  end

  def check_for_active_workers
    working_count > 1
  end

  def working_count
    delayed_jobs.count(:locked_at)
  end

  def pending_count
    delayed_jobs.count - working_count
  end

  def get_data(article, options={})
    query_url = get_query_url(article)
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

  def parse_data(result, article, options = {})
    # turn result into a hash for easier parsing later
    result = { 'data' => result } unless result.is_a?(Hash)

    # properly handle not found errors
    result = { 'data' => [] } if result[:status] == 404

    # return early if an error occured that is not a not_found error
    return result if result[:error]

    options.merge!(response_options)
    metrics = options[:metrics] || :citations

    events = get_events(result)

    { events: events,
      events_by_day: get_events_by_day(events, article),
      events_by_month: get_events_by_month(events),
      events_url: get_events_url(article),
      event_count: events.length,
      event_metrics: get_event_metrics(metrics => events.length) }
  end

  def get_events_by_day(events, article)
    events = events.reject { |event| event[:event_time].nil? || Date.iso8601(event[:event_time]) - article.published_on > 30 }

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

  def get_query_url(article)
    return nil unless article.doi.present?

    url % { :doi => article.doi_escaped }
  end

  def get_events_url(article)
    if events_url.present? && article.doi.present?
      events_url % { :doi => article.doi_escaped }
    end
  end

  def get_author(author)
    return '' if author.blank?

    name_parts = author.split(' ')
    family = name_parts.last
    given = name_parts.length > 1 ? name_parts[0..-2].join(' ') : ''

    [{ 'family' => String(family).titleize,
       'given' => String(given).titleize }]
  end

  # Custom validations that are triggered in state machine
  def validate_config_fields
    config_fields.each do |field|

      # Some fields can be blank
      next if name == "crossref" && field == :password
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

  def check_cache
    if ActionController::Base.perform_caching
      DelayedJob.delete_all(queue: "#{name}-cache-queue")
      delay(priority: 0, queue: "#{name}-cache-queue").expire_cache
    end
  end

  # Remove all retrieval records for this source that have never been updated,
  # return true if all records are removed
  def remove_all_retrievals
    rs = retrieval_statuses.where(:retrieved_at == '1970-01-01').delete_all
    retrieval_statuses.count == 0
  end

  # Create an empty retrieval record for every article for the new source
  def create_retrievals
    article_ids = RetrievalStatus.where(:source_id => id).pluck(:article_id)

    sql = "insert into retrieval_statuses (article_id, source_id, created_at, updated_at, scheduled_at) select id, #{id}, now(), now(), now() from articles"
    sql += " where articles.id not in (#{article_ids.join(",")})" if article_ids.any?

    ActiveRecord::Base.connection.execute sql
  end

  def cache_timeout
    30.seconds + (Article.count / 250).seconds
  end

  private

  def expire_cache
    update_column(:cached_at, Time.zone.now)
    source_url = "http://#{CONFIG[:server_name]}/api/v5/sources/#{name}?api_key=#{CONFIG[:api_key]}"
    get_result(source_url, timeout: cache_timeout)

    Rails.cache.write('status:timestamp', Time.zone.now.utc.iso8601)
    status_url = "http://#{CONFIG[:server_name]}/api/v5/status?api_key=#{CONFIG[:api_key]}"
    get_result(status_url, timeout: cache_timeout)
  end
end
