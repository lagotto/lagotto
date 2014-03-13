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

# Based on http://www.salsify.com/blog/delayed-jobs-callbacks-and-hooks-in-rails

require 'delayed_job'

class AlertPlugin < Delayed::Plugin

  callbacks do |lifecycle|
    lifecycle.around(:invoke_job) do |job, *args, &block|
      begin
        # Forward the call to the next callback in the callback chain
        block.call(job, *args)
      rescue Exception => error
        Alert.create(:exception => error,
                     :class_name => error.class.name,
                     :message => "#{error.message} in #{job.queue}",
                     :backtrace => error.backtrace)
        # Make sure we propagate the failure!
        raise error
      end
    end
  end

end