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

class RetrievalHistoryJob < Struct.new(:rh_ids)
  def perform
    rh_ids.each do | rh_id |
      rh = RetrievalHistory.find(rh_id)
      rh.delete_document
    end
  end

  def failure(job)
    # bring error into right format
    error = job.last_error.split("\n")
    message = error.shift
    exception = OpenStruct.new(backtrace: error)

    Alert.create(:class_name => "DelayedJobError", :message => "Failure in #{job.queue}: #{message}", :exception => exception, :source_id => source_id)
  end

  # override the default settings which are:
  # On failure, the job is scheduled again in 5 seconds + N ** 4, where N is the number of retries.
  # with the settings below we try 10 times within one hour, because we then queue jobs again anyway.
  def reschedule_at(time, attempts)
    case attempts
    when (0..4)
      interval = 1.minute
    when (5..6)
      interval = 5.minutes
    else
      interval = 10.minutes
    end
    time + interval
  end
end
