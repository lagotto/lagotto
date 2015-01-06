json.error @error

json.data do
  json.cache! ['v5', @status], skip_digest: true do
    json.(@status, :works_count, :works_last_day_count, :alerts_count, :workers_count, :active_jobs_count, :responses_count, :events_count, :requests_count, :requests_average, :users_count, :sources_active_count, :version, :couchdb_size, :update_date)
  end
end
