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
  task :start_all => :environment do

    Worker.delete_all

    cnt = 1

    Source.all.each do | source |

      # get the number of workers needed for a source
      workers = source.workers

      workers.times do
        # start the worker
        command = "cd #{Rails.root}; ./script/delayed_job --queue=#{source.name} --identifier=#{cnt} start"
        puts command
        system(command)

        # keep track of the worker we created
        worker  = Worker.new
        worker.identifier = cnt
        worker.queue = source.name
        worker.save

        cnt += 1
      end
    end
  end

  desc "Stop all the workers"
  task :stop_all => :environment do
    # stop all workers
    command = "cd #{Rails.root}; ./script/delayed_job stop"
    puts command
    system(command)
  end

  desc "Add one worker to a given source queue"
  task :add_to_source => :environment do

    if ENV['SOURCE']
      source = Source.find_by_name(ENV['SOURCE'])
      if source.nil?
        puts "Wrong source name"
      else
        # get an available identifier
        max = Worker.maximum('identifier')

        max += 1

        # start the worker
        command = "cd #{Rails.root}; ./script/delayed_job --queue=#{source.name} --identifier=#{max} start"
        puts command
        system(command)

        # keep track of the worker we created
        worker  = Worker.new
        worker.identifier = max
        worker.queue = source.name
        worker.save
      end
    else
      puts "Source required"
    end
  end

  desc "Start all the workers for a given source queue"
  task :start_source => :environment do
    # check to see if they are running or not
    # if they are not running, start them
    # all the workers for the source has to be not running for this command to work

    if ENV['SOURCE']
      source = Source.find_by_name(ENV['SOURCE'])
      if source.nil?
        puts "Wrong source name"
      else

        # get information about workers for the source
        workers = Worker.find_all_by_queue(source.name)

        total_workers = workers.size
        current_workers = 0

        # there isn't any record of the workers for this source, create them.
        if total_workers == 0

          source.workers.times do
            worker  = Worker.new
            worker.identifier = Worker.maximum('identifier') + 1
            worker.queue = source.name
            worker.save
          end

        else

          # check to see if any of the workers for the source are running or not
          workers.each do | worker |
            begin
              pid = IO.read("#{Rails.root}/tmp/pids/delayed_job.#{worker.identifier}.pid")
              Process.getpgid(pid.to_i)
              puts "#{worker.queue} #{worker.identifier} #{pid.to_i} is still running."
            rescue
              current_workers += 1
              puts "#{worker.queue} #{worker.identifier} #{pid.to_i} is not running."
            end
          end
        end

        puts "total #{total_workers} current #{current_workers}"

        # if all the workers are not running, start them.
        if total_workers == current_workers
          workers = Worker.find_all_by_queue(source.name)
          workers.each do |worker|
            command = "cd #{Rails.root}; ./script/delayed_job --queue=#{source.name} --identifier=#{worker.identifier} start"
            puts command
            system(command)
          end
        else
          puts "Could not start the workers.  Some or All workers are still running"
        end
      end
    else
      puts "Source required"
    end
  end

  desc "Stop workers for a given source queue"
  task :stop_source => :environment do
    if ENV['SOURCE']
      source = Source.find_by_name(ENV['SOURCE'])
      if source.nil?
        puts "Wrong source name"
      else

        # get information about workers for the source
        workers = Worker.find_all_by_queue(source.name)

        # stop the workers
        workers.each do | worker |
          command = "cd #{Rails.root}; ./script/delayed_job --identifier=#{worker.identifier} stop"
          puts command
          system(command)
        end
      end
    else
      puts "Source required"
    end
  end

  desc "Monitor workers"
  task :monitor => :environment do

    while true
      puts "monitoring workers "

      Worker.all.each do | worker |
        begin
          pid = IO.read("#{Rails.root}/tmp/pids/delayed_job.#{worker.identifier}.pid")
          Process.getpgid(pid.to_i)
          puts "#{worker.queue} #{worker.identifier} #{pid.to_i} running"
        rescue
          puts "ERROR #{worker.queue} #{worker.identifier} not running"
          # TODO email which process is having an issue
        end
      end

      # sleeps for 2 hours
      sleep(7200)
    end
  end

end