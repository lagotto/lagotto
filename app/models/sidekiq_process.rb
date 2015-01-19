class SidekiqProcess
  def workers_size
    @workers_size ||= workers.size
  end

  def workers
    @workers ||= Sidekiq::Workers.new
  end

  def stats
    @stats ||= Sidekiq::Stats.new
  end

  def current_status
    if workers_size > 0
      "working"
    elsif process_set.size > 0
      "waiting"
    else
      "stopped"
    end
  end

  def process_set
    @process_set ||= Sidekiq::ProcessSet.new
  end

  def pid
    process_set.first ? process_set.first["pid"] : nil
  end

  def pidfile
    "/var/www/#{ENV['APPLICATION']}/shared/tmp/pids/sidekiq.pid"
  end

  def logfile
    "/var/www/#{ENV['APPLICATION']}/shared/log/sidekiq.log"
  end

  def configfile
    "/var/www/#{ENV['APPLICATION']}/current/config/sidekiq.yml"
  end

  def stop
    if pid
      IO.write(pidfile, pid) unless File.exist? pidfile
      message = `/usr/bin/env bundle exec sidekiqctl stop #{pidfile} 10`
    else
      message = "No Sidekiq process running."
    end
  end

  def quiet
    if pid
      IO.write(pidfile, pid) unless File.exist? pidfile
      `/usr/bin/env bundle exec sidekiqctl quiet #{pidfile}`
      message = "Sidekiq turned quiet."
    else
      message = "No Sidekiq process running."
    end
  end

  def start
    if pid
      ps = process_set.first
      message = "Sidekiq process running, Sidekiq process started at #{Time.at(ps['started_at']).utc.iso8601}."
    else
      `/usr/bin/env bundle exec sidekiq --pidfile #{pidfile} --environment #{ENV['RAILS_ENV']} --logfile #{logfile} --config #{configfile} --daemon`
      message = "No Sidekiq process running, Sidekiq process started at #{Time.zone.now.utc.iso8601}."
    end
  end

  def monitor
    ps = process_set.first
    if ps.nil?
      start
      message = "No Sidekiq process running, Sidekiq process started at #{Time.zone.now.utc.iso8601}."
      Alert.create(:exception => "",
                   :class_name => "StandardError",
                   :message => message,
                   :level => Alert::FATAL)
      message
    else
      message = "Sidekiq process running, Sidekiq process started at #{Time.at(ps['started_at']).utc.iso8601}."
    end
  end
end
