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

require 'source_helper'
require 'cgi'
require 'ostruct'

class Source < ActiveRecord::Base
  include SourceHelper

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :retrieval_histories, :dependent => :destroy
  has_many :articles, :through => :retrieval_statuses
  has_many :delayed_jobs, :primary_key => "name", :foreign_key => "queue"
  has_many :error_messages
  belongs_to :group

  serialize :config, OpenStruct

  after_create :create_retrievals

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true 
  validates :workers, :presence => true, :numericality => { :only_integer => true }, :inclusion => { :in => 1..10, :message => "should be between 1 and 10" }  
  validates :timeout, :presence => true, :numericality => { :only_integer => true }, :inclusion => { :in => 1..3600, :message => "should be between 1 and 3600" }
  validates :wait_time, :presence => true, :numericality => { :only_integer => true }, :inclusion => { :in => 1..3600, :message => "should be between 1 and 3600" }
  validates :max_failed_queries, :presence => true, :numericality => { :only_integer => true }, :inclusion => { :in => 0..1000, :message => "should be between 0 and 1000" }
  validates :max_failed_query_time_interval, :presence => true, :numericality => { :only_integer => true }, :inclusion => { :in => 0..864000, :message => "should be between 0 and 864000" }

  # for job priority
  TOP_PRIORITY = 0
  
  scope :active, where(:active => true).order("group_id, display_name")
  scope :inactive, where(:active => false).order("group_id, display_name")
  scope :for_events, where("active = 1 AND name != 'relativemetric'").order("group_id, display_name")
  
  def to_param  # overridden, use name instead of id
    name
  end

  def get_data(article, options={})
    raise NotImplementedError, 'Children classes should override get_data method'
  end

  def queue_all_articles
    # determine if the source is active
    if active && (disable_until.nil? || disable_until < Time.zone.now)

      # reset disable_until value
      unless self.disable_until.nil?
        self.disable_until = nil
        save
      end
      
      rs = retrieval_statuses.pluck("retrieval_statuses.id")
      logger.debug "#{name} total articles queued #{rs.length}"
      
      rs.each_slice(job_batch_size) do | rs_ids |
        Delayed::Job.enqueue SourceJob.new(rs_ids, id), :queue => name
      end

    else
      raise Net::HTTPServiceUnavailable, "#{display_name} (#{name}) is either inactive or is disabled"
    end
  end

  def queue_articles
    sleep_interval = batch_time_interval
    # determine if the source is active
    if active
      queue_job = true

      # check to see if there has been many failures on trying to get data from the source
      check_for_failures

      # determine if the source is disabled or not
      unless self.disable_until.nil?
        queue_job = false

        if self.disable_until < Time.zone.now
          self.disable_until = nil
          save
          queue_job = true
        end
      end

      if queue_job
        # if there are jobs already queued, wait a little bit
        if get_queued_job_count > 0
          sleep_interval = wait_time
        else
          queue_article_jobs
        end
      end
    end

    return sleep_interval
  end

  def queue_article_jobs
    # find articles that need to be updated
    # not queued currently, scheduled_at in the past
    rs = retrieval_statuses.stale.pluck("retrieval_statuses.id")
    logger.debug "#{name} total articles queued #{rs.length}"

    rs.each_slice(job_batch_size) do | rs_ids |
      Delayed::Job.enqueue SourceJob.new(rs_ids, id), :queue => name
    end

  end

  def queue_article_job(retrieval_status, priority=Delayed::Worker.default_priority)
    Delayed::Job.enqueue SourceJob.new([retrieval_status.id], id), :queue => name, :priority => priority
  end

  def get_config_fields
    []
  end

  def get_queued_job_count
    Delayed::Job.count('id', :conditions => ["queue = ?", name])
  end

  def get_query_url(article)
    config.url % { :doi => CGI.escape(article.doi) }
  end

  def check_for_failures
    # condition for not adding more jobs and disabling the source

    failed_queries = ErrorMessage.where("source_id = :id and updated_at > :updated_date",
                                            {:id => id,
                                             :updated_date => (Time.zone.now - max_failed_query_time_interval.seconds)}).count(:id)

    if failed_queries > max_failed_queries
      ErrorMessage.create(:exception => "", :class_name => "StandardError",
                          :message => "#{display_name} has exceeded maximum failed queries. Disabling the source.", 
                          :source_id => id)
      # disable the source
      self.disable_until = Time.zone.now + disable_delay.seconds
      save
    end
  end
  
  # get the source-specific configuration from config/settings.yml, otherwise use general source settings in config/settings.yml, otherwise use default. 
  # Don't use merge! as APP_CONFIG is a constant
  def source_config
    OpenStruct.new(APP_CONFIG[name].nil? ? APP_CONFIG["source"] : APP_CONFIG["source"].merge(APP_CONFIG[name]))
  end
  
  def job_batch_size
    source_config.job_batch_size || 200
  end
  
  def batch_time_interval
    source_config.batch_time_interval || 1.hour
  end
  
  def staleness
    # staleness can be Integer or Array
    source_config.staleness || [ (1.month * 0.25) ]
    Array(source_config.staleness)
  end 
  
  def staleness_with_limits
    case staleness.length
    when 1
      ["any time"].zip(staleness)
    when 2
      ["in the last 7 days", "more than 7 days ago"].zip(staleness)
    when 3
      ["in the last 7 days", "in the last 31 days", "more than 31 days ago"].zip(staleness)
    when 4
      ["in the last 7 days", "in the last 31 days", "in the last year", "more than a year ago"].zip(staleness)
    end
  end
  
  def staleness=(value)
    source_config.staleness = value
  end
  
  def requests_per_day
    source_config.requests_per_day
  end
  
  def status
    if !active
      "inactive"
    elsif disable_until
      "disabled"
    elsif !(retrieval_statuses.where("event_count > 0").size > 0)
      "no events"
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
