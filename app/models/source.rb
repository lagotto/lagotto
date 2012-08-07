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
  belongs_to :group

  serialize :config, OpenStruct

  after_create :create_retrievals

  validates_presence_of :display_name
  validates_numericality_of :timeout, :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 3600
  validates_numericality_of :workers, :only_integer => true, :greater_than => 0, :less_than => 10
  validates_numericality_of :wait_time, :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 3600
  validates_numericality_of :max_failed_queries, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :max_failed_query_time_interval, :only_integer => true, :greater_than_or_equal_to => 0

  # for job priority
  TOP_PRIORITY = 0

  def get_data(article, options={})
    raise NotImplementedError, 'Children classes should override get_data method'
  end

  def queue_all_articles
    # determine if the source is active
    if active && (disable_until.nil? || disable_until < Time.now.utc)

      # reset disable_until value
      unless self.disable_until.nil?
        self.disable_until = nil
        save
      end

      job_batch_size = get_job_batch_size

      # grab all the articles
      retrieval_statuses = RetrievalStatus.joins(:article, :source).
          where('sources.id = ?
               and articles.published_on < ?
               and queued_at is NULL',
                id, Time.zone.today).pluck("retrieval_statuses.id")

      retrieval_statuses.each_slice(job_batch_size) do | rs_ids |
        Delayed::Job.enqueue SourceJob.new(rs_ids, id), :queue => name
      end

    else
      Rails.logger.error "#{name} is either inactive or is disabled."
      raise "#{display_name} (#{name}) is either inactive or is disabled"
    end
  end

  def queue_articles

    # get the source specific configurations
    source_config = YAML.load_file("#{Rails.root}/config/source_configs.yml")[Rails.env]
    source_config = source_config[name]

    if !source_config.has_key?('batch_time_interval') || !source_config.has_key?('staleness')
      Rails.logger.error "#{display_name}: batch_time_interval is missing or staleness is missing"
      raise "#{display_name}: batch_time_interval is missing or staleness is missing"
      return
    end

    source_config['batch_time_interval'] = parse_time_config(source_config['batch_time_interval'])
    source_config['staleness'] = parse_time_config(source_config['staleness'])

    # determine if the source is active
    if active
      queue_job = true

      # check to see if there has been many failures on trying to get data from the source
      check_for_failures

      # determine if the source is disabled or not
      unless self.disable_until.nil?
        queue_job = false

        if self.disable_until < Time.now.utc
          self.disable_until = nil
          save
          queue_job = true
        end
      end

      if queue_job
        # if there are jobs already queued, wait a little bit
        if get_queued_job_count > 0
          source_config['batch_time_interval'] = wait_time
        else
          queue_article_jobs(source_config)
        end
      end
    end

    return source_config['batch_time_interval']
  end

  def queue_article_jobs(source_config)
    # find articles that need to be updated

    job_batch_size = get_job_batch_size

    # not queued currently
    # stale from updated_at
    retrieval_statuses = RetrievalStatus.joins(:article, :source).
        where('sources.id = ?
               and articles.published_on < ?
               and queued_at is NULL
               and retrieved_at < TIMESTAMPADD(SECOND, - ?, UTC_TIMESTAMP())',
              id, Time.zone.today, source_config['staleness'].seconds.to_i).pluck("retrieval_statuses.id")

    Rails.logger.debug "#{name} total article queued #{retrieval_statuses.length}"

    retrieval_statuses.each_slice(job_batch_size) do | rs_ids |
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

    failed_queries = RetrievalHistory.where("source_id = :id and status = :status and updated_at > :updated_date",
                                            {:id => id,
                                             :status => RetrievalHistory::ERROR_MSG,
                                             :updated_date => (Time.now.utc - max_failed_query_time_interval.seconds)}).count(:id)

    if failed_queries > max_failed_queries
      Rails.logger.error "#{display_name} has exceeded maximum failed queries.  Disabling the source."
      # disable the source
      self.disable_until = Time.now.utc + disable_delay.seconds
      save
    end
  end

  private

  def parse_time_config(time_interval_config)
    unless time_interval_config.nil?
      index = time_interval_config.index('.')
      number = time_interval_config[0,index]
      method = time_interval_config[index + 1, time_interval_config.length]
      return number.to_i.send(method)
    end
  end

  def get_job_batch_size
    source_config = YAML.load_file("#{Rails.root}/config/source_configs.yml")[Rails.env]
    job_batch_size = source_config['job_batch_size']
    max_job_batch_size = source_config['max_job_batch_size']
    default_job_batch_size = source_config['default_job_batch_size']
    if job_batch_size.nil?
      job_batch_size = default_job_batch_size
    elsif not (job_batch_size > 0 and job_batch_size < max_job_batch_size)
      job_batch_size = default_job_batch_size
    end
    job_batch_size
  end

  def create_retrievals
    # Create an empty retrieval record for every article for the new source
    conn = RetrievalStatus.connection
    sql = "insert into retrieval_statuses (article_id, source_id, created_at, updated_at) select id, #{id}, now(), now() from articles"
    conn.execute sql
  end
end
