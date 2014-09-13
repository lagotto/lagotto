object false

node(:error) { nil }

child @status => :data do
  attributes :articles_count, :articles_last30_count, :alerts_last_day_count, :workers_count, :delayed_jobs_active_count, :responses_count, :events_count, :requests_count, :users_count, :sources_active_count, :version, :couchdb_size, :update_date
end
