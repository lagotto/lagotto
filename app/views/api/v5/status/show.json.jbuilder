json.error @error

json.data do
  json.cache! ['v5', @status], skip_digest: true do
    json.(@status, :articles_count, :articles_last30_count, :alerts_count, :workers_count, :delayed_jobs_active_count, :responses_count, :events_count, :requests_count, :users_count, :sources_active_count, :version, :couchdb_size, :update_date)
  end
end
