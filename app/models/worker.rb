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

  attr_reader :id, :pid, :state, :memory, :created_at

  def self.all
    Dir[Rails.root.join("tmp/pids/delayed_job*pid")].map { |file| Worker.new(file) }
  end

  def self.find(param)
    all.detect { |f| f.id == param } || raise(ActiveRecord::RecordNotFound)
  end

  def self.count
    all.count
  end

  def self.monitor
    expected = (CONFIG[:workers] || 1).to_i
    if count < expected
      report = Report.find_or_create_by_name(:name => "missing_workers_report")
      report.send_missing_workers_report
    end
    { expected: expected,
      running: count }
  end

  def initialize(file)
    name = File.basename(file).split(".")
    @id = name.length == 3 ? name[1] : "n/a"
    @pid = IO.read(file).strip
    @state = state
    @memory = memory
    @created_at = File.ctime(file)
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
end