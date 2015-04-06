json.meta do
  json.status "ok"
  json.message_type "work_type"
  json.message_version "6.0.0"
end

json.work_type do
  json.cache! ['v6', @work_type], skip_digest: true do
    json.(@work_type, :id, :title, :container, :update_date)
  end
end
