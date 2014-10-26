class Status
  # include HTTP request helpers
  include Networkable

  RELEASES_URL = "https://api.github.com/repos/articlemetrics/lagotto/releases"

  def articles_count
    Rails.cache.read("status/articles_count/#{update_date}").to_i
  end

  def articles_count=(timestamp)
    Rails.cache.write("status/articles_count/#{timestamp}", Article.count)
  end

  def articles_last30_count
    Rails.cache.read("status/articles_last30_count/#{update_date}").to_i
  end

  def articles_last30_count=(timestamp)
    Rails.cache.write("status/articles_last30_count/#{timestamp}",
                      Article.last_x_days(30).count)
  end

  def events_count
    Rails.cache.read("status/events_count/#{update_date}").to_i
  end

  def events_count=(timestamp)
    Rails.cache.write("status/events_count/#{timestamp}",
                      RetrievalStatus.joins(:source).where("state > ?", 0)
                        .where("name != ?", "relativemetric").sum(:event_count))
  end

  def alerts_last_day_count
    Rails.cache.read("status/alerts_last_day_count/#{update_date}").to_i
  end

  def alerts_last_day_count=(timestamp)
    Rails.cache.write("status/alerts_last_day_count/#{timestamp}",
                      Alert.total_errors(1).count)
  end

  def workers_count
    Worker.count
  end

  def delayed_jobs_active_count
    Rails.cache.read("status/alerts_last_day_count/#{update_date}").to_i
  end

  def delayed_jobs_active_count=(timestamp)
    Rails.cache.write("status/delayed_jobs_active_count/#{timestamp}",
                      DelayedJob.count)
  end

  def responses_count
    Rails.cache.read("status/responses_count/#{update_date}").to_i
  end

  def responses_count=(timestamp)
    Rails.cache.write("status/responses_count/#{timestamp}",
                      ApiResponse.total(1).count)
  end

  def requests_count
    Rails.cache.fetch("status/requests_count/#{update_date}").to_i
  end

  def requests_count=(timestamp)
    Rails.cache.write("status/requests_count/#{timestamp}",
                      ApiRequest.total(1).count)
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
    Rails.cache.read("status/current_version/#{update_date}") || version
  end

  def current_version=(timestamp)
    result = get_result(RELEASES_URL)
    result = result.is_a?(Array) ? result.first : {}
    Rails.cache.write("status/current_version/#{timestamp}",
                      result.fetch("tag_name", "v.#{version}")[2..-1])
  end

  def outdated_version?
    !Gem::Dependency.new("", "~> #{version}").match?("", current_version)
  end

  def couchdb_size
    RetrievalStatus.new.get_lagotto_database["disk_size"] || 0
  end

  def update_date
    Rails.cache.read("status:timestamp") || "1970-01-01T00:00:00Z"
  end

  def update_date=(timestamp)
    Rails.cache.write("status:timestamp", timestamp)
  end

  def cache_key
    "status/#{update_date}"
  end

  def update_cache
    DelayedJob.delete_all(queue: "status-cache")
    delay(priority: 1, queue: "status-cache").write_cache
  end

  def write_cache
    # update cache_key as last step so that old version works until we are done
    timestamp = Time.zone.now.utc.iso8601

    # loop through cached attributes we want to update
    [:articles_count,
     :articles_last30_count,
     :events_count,
     :alerts_last_day_count,
     :delayed_jobs_active_count,
     :responses_count,
     :requests_count,
     :current_version,
     :update_date].each { |cached_attr| send("#{cached_attr}=", timestamp) }
  end
end
