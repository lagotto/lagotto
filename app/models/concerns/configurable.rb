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

module Configurable
  extend ActiveSupport::Concern

  included do

    # Array of hashes for forms, defined in subclassed sources
    def get_config_fields
      []
    end

    # List of field names for strong_parameters and validations
    def config_fields
      get_config_fields.map { |f| f[:field_name].to_sym }
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

    def schedule_at
      last_job = DelayedJob.where(queue: name).maximum(:run_at)
      return Time.zone.now if last_job.nil?

      last_job + batch_interval
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

    def cron_line
      config.cron_line || "* 05 * * *"
    end

    def cron_line=(value)
      config.cron_line = value
    end

    # is this source no longer accepting new data?
    def obsolete
      config.obsolete || false
    end

    def obsolete=(value)
      config.obsolete = value
    end

    alias_method :obsolete?, :obsolete

  end
end
