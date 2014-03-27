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

namespace :workers do

  desc "Start all the workers"
  task :start => :environment do

    status = Worker.start
    puts status[:message] if status[:message]
    if status[:running] < status[:expected]
      puts "Not all workers could be started."
    else
      puts "All #{status[:running]} workers started."
    end

  end

  desc "Stop all the workers"
  task :stop => :environment do

    status = Worker.stop
    puts status[:message] if status[:message]
    if status[:running] > 0
      puts "Not all workers could be stopped."
    else
      puts "All workers stopped."
    end

  end

  desc "Monitor workers"
  task :monitor => :environment do

    status = Worker.monitor
    puts status[:message] if status[:message]
    if status[:expected] > status[:running]
      puts "Missing workers report sent."
    end
    puts "#{status[:expected]} workers expected, #{status[:running]} workers running."

  end

end