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

require 'custom_error'
require 'timeout'

class QueueJob < Struct.new(:source_id)

  include CustomError

  QueueJobExceptions = [SourceInactiveError].freeze

  def perform
    source = Source.find(source_id)
    source.start_queueing

    # Check that source is queueing
    # Otherwise raise an error and reschedule the job
    raise SourceInactiveError unless source.queueing?

    Timeout.timeout(5.minutes) do
      source.queue_stale_articles
    end
  rescue Timeout::Error
    source = Source.find(source_id)
    Alert.create(:exception => "",
                 :class_name => "Timeout::Error",
                 :message => "DelayedJob timeout error for #{source.display_name}",
                 :status => 408,
                 :source_id => source.id)
    return false
  rescue *QueueJobExceptions
    Alert.create(:exception => "",
                 :class_name => "SourceInactiveError",
                 :message => "Source #{source.display_name} could not transition to queueing state",
                 :source_id => source.id)
    return false
  rescue StandardError => e
    Alert.create(:exception => e, :message => e.message, :source_id => source.id)
    return false
  end

  def failure(job)
    source = Source.find(source_id)
    Alert.create(:exception => "", :class_name => "DelayedJobError", :message => "Failure in #{job.queue}: #{job.last_error}", :source_id => source.id)
  end

  def after(job)
    source = Source.find(source_id)
    source.stop_queueing
  end

  # override the default settings which are:
  # On failure, the job is scheduled again in 5 seconds + N ** 4, where N is the number of retries.
  # with the settings below we try for 23 hours. Max_attempts is 25
  def reschedule_at(attempts, time)
    case attempts
    when (0..5)
      interval = 1.minute
    when (6..10)
      interval = 5.minutes
    when (11..15)
      interval = 30.minutes
    when (16..20)
      interval = 1.hour
    else
      interval = 3.hours
    end
    self.class.db_time_now + interval
  end
end