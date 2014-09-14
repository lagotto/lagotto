class Status
  # include HTTP request helpers
  include Networkable

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
    DelayedJob.count
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
                      ApiRequest.where("created_at > ?",
                                       Time.zone.now - 1.day).count)
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
     :responses_count,
     :requests_count,
     :update_date].each { |cached_attr| send("#{cached_attr}=", timestamp) }
  end
end
