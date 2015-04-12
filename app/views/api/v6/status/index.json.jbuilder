json.meta do
  json.status "ok"
  json.set! :"message-type", "status-list"
  json.set! :"message-version", "6.0.0"
  json.total @status.total_entries
  json.total_pages @status.per_page > 0 ? @status.total_pages : 1
  json.page @status.total_entries > 0 ? @status.current_page : 1
end

json.status @status do |status|
  json.cache! ['v6', status, @user], skip_digest: true do
    json.(status, :id, :works_count, :works_new_count, :sources, :events_count, :responses_count, :requests_count, :requests_average, :version)

    if current_user && current_user.is_admin_or_staff?
      json.(status, :alerts_count, :db_size)
    end

    json.(status, :timestamp)
  end
end
