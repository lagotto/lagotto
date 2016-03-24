json.meta do
  json.status "ok"
  json.set! :"message-type", "status-list"
  json.set! :"message-version", "v7"
  json.total @status.total_entries
  json.total_pages @status.per_page > 0 ? @status.total_pages : 1
  json.page @status.total_entries > 0 ? @status.current_page : 1
end

json.status @status do |status|
  json.cache! ['v7', status, current_user], skip_digest: true do
    json.(status, :id, :works_count, :works_new_count, :relations_count, :contributors_count, :publishers_count, :agents, :events_count, :responses_count, :deposits_count, :requests_count, :requests_average, :version)

    if current_user && current_user.is_admin_or_staff?
      json.(status, :notifications_count, :db_size)
    end

    json.(status, :timestamp)
  end
end
