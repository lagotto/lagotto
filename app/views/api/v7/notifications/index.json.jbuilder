json.meta do
  json.status "ok"
  json.set! :"message-type", "notification-list"
  json.set! :"message-version", "v7"
  json.total @notifications.total_entries
  json.total_pages @notifications.per_page > 0 ? @notifications.total_pages : 1
  json.page @notifications.total_entries > 0 ? @notifications.current_page : 1
end

json.notifications @notifications do |notification|
  json.cache! ['v7', notification], skip_digest: true do
    json.(notification, :id, :level, :class_name, :message, :status, :hostname, :target_url, :source_id, :work_id, :deposit_id, :unresolved, :timestamp)
  end
end
