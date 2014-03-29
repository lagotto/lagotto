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

  def perform
    source = Source.find(source_id)
    source.start_queueing

    # Check that source is queueing
    # Otherwise raise an error and reschedule the job
    raise SourceInactiveError, "#{source.display_name} is not in queueing state" unless source.queueing?

    source.queue_stale_articles
  end

  def error(job, exception)
    # don't create alert for this error
    unless exception.kind_of?(SourceInactiveError)
      source = Source.find(source_id)
      Alert.create(:exception => exception, :message => exception.message, :source_id => source.id)
    end
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
    Time.zone.now + interval
  end
end