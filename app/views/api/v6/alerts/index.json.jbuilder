json.meta do
  json.status "ok"
  json.message_type "alert-list"
  json.message_version "6.0.0"
  json.total @alerts.total_entries
  json.total_pages @alerts.per_page > 0 ? @alerts.total_pages : 1
  json.page @alerts.total_entries > 0 ? @alerts.current_page : 1
end

json.data @alerts do |alert|
  json.cache! ['v6', alert], skip_digest: true do
    json.(alert, :id, :level, :class_name, :message, :status, :hostname, :target_url, :source, :work, :unresolved, :create_date)
  end
end
