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

Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 10
Delayed::Worker.default_priority = 3
Delayed::Worker.max_run_time = 90.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.delay_jobs = !Rails.env.test?

# monkeypatch delayed_jobs to catch worker errors
module Delayed
  class Command

  def run(worker_name = nil)
      Dir.chdir(Rails.root)

      Delayed::Worker.after_fork
      Delayed::Worker.logger ||= Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))

      worker = Delayed::Worker.new(@options)
      worker.name_prefix = "#{worker_name} "
      worker.start
    rescue => e
      # added this line
      Alert.create(:exception => e)

      Rails.logger.fatal e
      STDERR.puts e.message
      exit 1
    end
  end
end
