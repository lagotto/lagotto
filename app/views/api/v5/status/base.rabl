object @status

attributes :articles_count, :articles_last30_count, :events_count, :version, :update_date

if current_user.try(:is_admin_or_staff?)
  attributes :alerts_last_day_count, :workers_count, :delayed_jobs_active_count, :responses_count, :requests_count, :users_count, :sources_active_count, :couchdb_size
end
