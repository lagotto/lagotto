class Status
  # include HTTP request helpers
  include Networkable

  RELEASES_URL = "https://api.github.com/repos/articlemetrics/lagotto/releases"

  def works_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/works_count/#{update_date}").to_i
    else
      Work.count
    end
  end

  def works_count=(timestamp)
    Rails.cache.write("status/works_count/#{timestamp}", Work.count)
  end

  def works_last_day_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/works_last_day_count/#{update_date}").to_i
    else
      Work.last_x_days(1).count
    end
  end

  def works_last_day_count=(timestamp)
    Rails.cache.write("status/works_last_day_count/#{timestamp}",
                      Work.last_x_days(1).count)
  end

  def events_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/events_count/#{update_date}").to_i
    else
      RetrievalStatus.joins(:source).where("state > ?", 0)
        .where("name != ?", "relativemetric").sum(:event_count)
    end
  end

  def events_count=(timestamp)
    Rails.cache.write("status/events_count/#{timestamp}",
                      RetrievalStatus.joins(:source).where("state > ?", 0)
                        .where("name != ?", "relativemetric").sum(:event_count))
  end

  def alerts_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/alerts_count/#{update_date}").to_i
    else
      Alert.errors.count
    end
  end

  def alerts_count=(timestamp)
    Rails.cache.write("status/alerts_count/#{timestamp}",
                      Alert.errors.count)
  end

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

  def process_pid
    process_set.first ? process_set.first["pid"] : nil
  end

  def process_pidfile
    "/var/www/#{ENV['APPLICATION']}/shared/tmp/pids/sidekiq.pid"
  end

  def process_logfile
    "/var/www/#{ENV['APPLICATION']}/shared/log/sidekiq.log"
  end

  def process_configfile
    "/var/www/#{ENV['APPLICATION']}/current/config/sidekiq.yml"
  end

  def process_stop
    if process_pid
      IO.write(process_pidfile, process_pid) unless File.exist? process_pidfile
      message = `/usr/bin/env bundle exec sidekiqctl stop #{process_pidfile} 10`
    else
      message = "No Sidekiq process running."
    end
  end

  def process_quiet
    if process_pid
      IO.write(process_pidfile, process_pid) unless File.exist? process_pidfile
      `/usr/bin/env bundle exec sidekiqctl quiet #{process_pidfile}`
      message = "Sidekiq turned quiet."
    else
      message = "No Sidekiq process running."
    end
  end

  def process_start
    if process_pid
      ps = process_set.first
      message = "Sidekiq process running, Sidekiq process started at #{Time.at(ps['started_at']).utc.iso8601}."
    else
      `/usr/bin/env bundle exec sidekiq --pidfile #{process_pidfile} --environment #{ENV['RAILS_ENV']} --logfile #{process_logfile} --config #{process_configfile} --daemon`
      message = "No Sidekiq process running, Sidekiq process started at #{Time.zone.now.utc.iso8601}."
    end
  end

  def process_monitor
    ps = process_set.first
    if ps.nil?
      process_start
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

  def responses_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/responses_count/#{update_date}").to_i
    else
      ApiResponse.total(1).count
    end
  end

  def responses_count=(timestamp)
    Rails.cache.write("status/responses_count/#{timestamp}",
                      ApiResponse.total(1).count)
  end

  def requests_count
    if ActionController::Base.perform_caching
      Rails.cache.fetch("status/requests_count/#{update_date}").to_i
    else
      ApiRequest.total(1).count
    end
  end

  def requests_count=(timestamp)
    Rails.cache.write("status/requests_count/#{timestamp}",
                      ApiRequest.total(1).count)
  end

  def requests_average
    if ActionController::Base.perform_caching
      Rails.cache.fetch("status/requests_average/#{update_date}").to_i
    else
      ApiRequest.total(1).average("duration").to_i
    end
  end

  def requests_average=(timestamp)
    Rails.cache.write("status/requests_average/#{timestamp}",
                      ApiRequest.total(1).average("duration").to_i)
  end

  def users_count
    User.count
  end

  def sources_active_count
    Source.active.count
  end

  def sources_working_count
    Source.working.count
  end

  def sources_waiting_count
    Source.waiting.count
  end

  def sources_disabled_count
    Source.disabled.count
  end

  def sources_inactive_count
    Source.inactive.count
  end

  def version
    Rails.application.config.version
  end

  def current_version
    if ActionController::Base.perform_caching
      Rails.cache.read("status/current_version/#{update_date}") || version
    else
      result = get_result(RELEASES_URL)
      result = result.is_a?(Array) ? result.first : {}
      result.fetch("tag_name", "v.#{version}")[2..-1]
    end
  end

  def current_version=(timestamp)
    result = get_result(RELEASES_URL)
    result = result.is_a?(Array) ? result.first : {}
    Rails.cache.write("status/current_version/#{timestamp}",
                      result.fetch("tag_name", "v.#{version}")[2..-1])
  end

  def outdated_version?
    Gem::Version.new(current_version) > Gem::Version.new(version)
  end

  def couchdb_size
    RetrievalStatus.new.get_lagotto_database["disk_size"] || 0
  end

  def update_date
    if ActionController::Base.perform_caching
      Rails.cache.read("status:timestamp") || "1970-01-01T00:00:00Z"
    else
      Time.zone.now.utc.iso8601
    end
  end

  def update_date=(timestamp)
    Rails.cache.write("status:timestamp", timestamp)
  end

  def cache_key
    "status/#{update_date}"
  end

  def write_cache
    # update cache_key as last step so that old version works until we are done
    timestamp = Time.zone.now.utc.iso8601

    # loop through cached attributes we want to update
    [:works_count,
     :works_last_day_count,
     :events_count,
     :alerts_count,
     :responses_count,
     :requests_count,
     :requests_average,
     :current_version,
     :update_date].each { |cached_attr| send("#{cached_attr}=", timestamp) }
  end
end
