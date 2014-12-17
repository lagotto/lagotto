# encoding: UTF-8

require 'csv'

class Worker
  PROC_STATS = { "D" => "sleeping",
                 "R" => "running",
                 "S" => "waiting",
                 "T" => "stopped",
                 "Z" => "defunct" }

  def self.all
    ps = `ps ux | grep delayed_jo[b] | awk '{ print $2,$3,$4,$8,$11 }'`
    ps.split("\n").map do |proc|
      p = proc.split(" ")
      state = PROC_STATS.fetch(p[3][0], "unknown")
      id = p[4].split(".").length == 1 ? "0" : p[4].split(".").last

      OpenStruct.new(pid: p[0].to_i, cpu: p[1].to_f, memory: p[2].to_f, state: state, id: id)
    end
  end

  def self.find(param)
    all.find { |f| f.id == param } || fail(ActiveRecord::RecordNotFound)
  end

  def self.count
    all.length
  end

  def self.start
    expected = (ENV['WORKERS']).to_i
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
                   :message => message,
                   :level => Alert::FATAL)
    end

    # system call returns before all workers are finished starting
    sleep 5

    status = { expected: expected, running: count, message: message }
  end

  def self.stop
    expected = (ENV['WORKERS'] || 1).to_i
    status = { expected: expected, running: count, message: nil }

    # no workers are running
    return status if count == 0

    # stop all workers
    unless system({'RAILS_ENV' => Rails.env}, *%w(script/delayed_job stop))
      message = "Error stopping workers, #{count} workers still running"
      Alert.create(:exception => "",
                   :class_name => "StandardError",
                   :message => message,
                   :level => Alert::FATAL)
    end

    status = { expected: expected, running: count, message: message }
  end

  def self.monitor
    expected = (ENV['WORKERS'] || 0).to_i
    if count < expected
      message = "Error monitoring workers, only #{count} of #{expected} workers running. Workers restarted."
      Alert.create(:exception => "",
                   :class_name => "StandardError",
                   :message => message)
      report = Report.where(name: "missing_workers_report").first
      report.send_missing_workers_report

      # restart workers
      Worker.start
    end

    status = { expected: expected, running: count, message: message }
  end
end
