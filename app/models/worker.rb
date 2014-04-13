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

require 'csv'

class Worker

  include Comparable
  include Enumerable

  attr_reader :id, :pid, :state, :memory, :queue, :locked_at, :created_at

  def self.files
    Dir[Rails.root.join("tmp/pids/delayed_job*pid")]
  end

  def self.count
    files.count
  end

  def self.all
    files.map { |file| Worker.new(file) }
  end

  def self.find(param)
    all.detect { |f| f.id == param } || raise(ActiveRecord::RecordNotFound)
  end

  def self.start
    expected = (CONFIG[:workers] || 1).to_i
    status = { expected: expected, running: count, message: nil }

    # all workers are running
    return status if count == expected

    # not enough workers are running, stop them first
    Worker.stop if count > 0

    # start all workers, log errors
    unless system({'RAILS_ENV' => Rails.env}, *%W(script/delayed_job -n #{expected} start))
      message = "Error starting workers, only #{count} of #{expected} workers running."
      Alert.create(:exception => "",
                   :class_name => "StandardError",
                   :message => message)
    end

    # system call returns before all workers are finished starting
    sleep 5

    status = { expected: expected, running: count, message: message }
  end

  def self.stop
    expected = (CONFIG[:workers] || 1).to_i
    status = { expected: expected, running: count, message: nil }

    # no workers are running
    return status if count == 0

    # stop all workers
    unless system({'RAILS_ENV' => Rails.env}, *%W(script/delayed_job stop))
      message = "Error stopping workers, #{count} workers still running"
      Alert.create(:exception => "",
                   :class_name => "StandardError",
                   :message => message)
    end

    status = { expected: expected, running: count, message: message }
  end

  def self.monitor
    expected = (CONFIG[:workers] || 1).to_i
    if count < expected
      message = "Error monitoring workers, only #{count} of #{expected} workers running. Workers restarted."
      Alert.create(:exception => "",
                   :class_name => "StandardError",
                   :message => message)
      report = Report.find_by_name("missing_workers_report")
      report.send_missing_workers_report

      # restart workers
      Worker.start
    end

    status = { expected: expected, running: count, message: message }
  end

  def initialize(file)
    name = File.basename(file).split(".")
    @id = name.length == 3 ? name[1] : "n/a"
    @pid = IO.read(file).strip
    @memory = memory
    @state = state
    @queue = queue
    @locked_at = locked_at
    @created_at = File.ctime(file).utc
  end

  def <=> other
    self.id <=> other.id
  end

  def each &block
    @workers.each do |worker|
      if block_given?
        block.call worker
      else
        yield worker
      end
    end
  end

  def proc
    proc = IO.read("/proc/#{pid}/status")
    proc = CSV.parse(proc, { :col_sep => ":\t" })
    proc = proc.inject({}) { |h, nvp| h[nvp[0]] = nvp[1]; h }
  rescue
    {}
  end

  def state
    proc["State"]
  end

  def memory
    proc["VmRSS"] ? proc["VmRSS"].strip : nil
  end

  def job
    DelayedJob.where("right(locked_by,?) = ?", @pid.length, @pid).first || OpenStruct.new(queue: nil, run_at: nil)
  end

  def queue
    job.queue
  end

  def locked_at
    job.locked_at
  end
end
