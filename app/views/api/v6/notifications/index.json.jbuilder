json.meta do
  json.status "ok"
  json.set! :"message-type", "notification-list"
  json.set! :"message-version", "6.0.0"
  json.total @notifications.total_entries
  json.total_pages @notifications.per_page > 0 ? @notifications.total_pages : 1
  json.page @notifications.total_entries > 0 ? @notifications.current_page : 1
end

json.notifications @notifications do |notification|
  json.cache! ['v6', notification], skip_digest: true do
    json.(notification, :id, :level, :class_name, :message, :status, :hostname, :target_url, :source, :work, :unresolved, :timestamp)
  end
end
