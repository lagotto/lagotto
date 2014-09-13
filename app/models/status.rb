class Status
  # include HTTP request helpers
  include Networkable

  attr_reader :articles_count, :events_count, :sources_disabled_count, :alerts_last_day_count, :workers_count, :delayed_jobs_active_count, :responses_count, :requests_count, :users_count, :version, :couchdb_size, :mysql_size, :update_date, :cache_key

  def articles_count
    Rails.cache.fetch("status/articles_count/#{update_date}") { Article.count }
  end

  def articles_last30_count
    Rails.cache.fetch("status/articles_last30_count/#{update_date}") { Article.last_x_days(30).count }
  end

  def events_count
    Rails.cache.fetch("status/events_count/#{update_date}") do
      RetrievalStatus.joins(:source).where("state > ?", 0).where("name != ?", "relativemetric").sum(:event_count)
    end
  end

  def alerts_last_day_count
    Rails.cache.fetch("status/alerts_last_day_count/#{update_date}") do
      Alert.total_errors(1).count
    end
  end

  def workers_count
    Worker.count
  end

  def delayed_jobs_active_count
    DelayedJob.count
  end

  def responses_count
    Rails.cache.fetch("status/responses_count/#{update_date}") { ApiResponse.total(1).count }
  end

  def requests_count
    Rails.cache.fetch("status/requests_count/#{update_date}")  do
      ApiRequest.where("created_at > ?", Time.zone.now - 1.day).count
    end
  end

  def users_count
    User.count
  end

  def sources_active_count
    Source.active.count
  end

  def version
    Rails.application.config.version
  end

  def couchdb_size
    RetrievalStatus.new.get_lagotto_database["disk_size"] || 0
  end

  def update_date
    Rails.cache.fetch('status:timestamp') { Time.zone.now.utc.iso8601 }
  end

  def cache_key
    "status/#{update_date}"
  end

  def status_url
    "http://#{CONFIG[:hostname]}/api/v5/status?api_key=#{CONFIG[:api_key]}"
  end

  def update_cache
    Rails.cache.write('status:timestamp', Time.zone.now.utc.iso8601)
    DelayedJob.delete_all(queue: "status-cache")
    delay(priority: 1, queue: "status-cache").get_result(status_url, timeout: 900)
  end
end
