json.meta do
  json.status "ok"
  json.message_type "status-list"
  json.message_version "6.0.0"
  json.total @status.total_entries
  json.total_pages @status.per_page > 0 ? @status.total_pages : 1
  json.page @status.total_entries > 0 ? @status.current_page : 0
end

json.status @status do |status|
  json.cache! ['v6', status, @user], skip_digest: true do
    json.(status, :id, :works_count, :works_new_count, :sources, :events_count, :responses_count, :requests_count, :requests_average, :version, :update_date)

    if current_user && current_user.is_admin_or_staff?
      json.(status, :alerts_count, :db_size)
    end
  end
end
