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

module Statable
  extend ActiveSupport::Concern

  included do
    state_machine :initial => :available do
      state :available, value: 0 # source available, but not installed
      state :retired, value: 1   # source installed, but no longer accepting new data
      state :inactive, value: 2  # source disabled by admin
      state :disabled, value: 3  # can't queue or process jobs, generates alert
      state :waiting, value: 5   # source active, waiting for next job
      state :working, value: 6   # processing jobs

      state all - [:available, :retired, :inactive] do
        def active?
          true
        end
      end

      state all - [:working, :waiting, :disabled] do
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

      after_transition :available => any - [:available, :retired] do |source|
        source.create_retrievals
      end

      after_transition :to => :inactive do |source|
        source.remove_queues
        source.update_attributes(run_at: Time.zone.now + 5.years)
      end

      after_transition :inactive => [:working] do |source|
        source.update_attributes(run_at: Time.zone.now)
      end

      after_transition any - [:disabled] => :disabled do |source|
        Alert.create(:exception => "", :class_name => "TooManyErrorsBySourceError",
                     :message => "#{source.display_name} has exceeded maximum failed queries. Disabling the source.",
                     :source_id => source.id)
        source.update_attributes(run_at: Time.zone.now + source.disable_delay)
        report = Report.find_by_name("disabled_source_report")
        report.send_disabled_source_report(source.id)
      end

      after_transition :to => :waiting do |source|
        if source.queueable
          source.update_attributes(run_at: source.run_at + source.batch_time_interval)
        else
          cron_parser = CronParser.new(source.cron_line)
          source.update_attributes(run_at: cron_parser.next(Time.zone.now))
        end
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
        transition [:available, :inactive] => :working
        transition any => same
      end

      event :inactivate do
        transition any => :inactive
      end

      event :disable do
        transition any => :disabled
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
        transition [:waiting] => :working
        transition any => same
      end

      event :stop_working do
        transition [:working] => :waiting
      end

      event :start_waiting do
        transition any => :waiting
      end
    end
  end
end
