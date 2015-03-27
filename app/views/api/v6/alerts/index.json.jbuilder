json.total @alerts.total_entries
json.total_pages (@alerts.total_entries.to_f / @alerts.per_page).ceil
json.page @alerts.total_entries > 0 ? @alerts.current_page : 0
json.error @error

json.data @alerts do |alert|
  json.cache! ['v6', alert], skip_digest: true do
    json.(alert, :id, :level, :class_name, :message, :status, :hostname, :target_url, :source, :work, :unresolved, :create_date)
  end
end
