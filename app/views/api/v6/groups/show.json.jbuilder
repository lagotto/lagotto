json.meta do
  json.status "ok"
  json.message_type "group"
  json.message_version "6.0.0"
end

json.group do
  json.cache! ['v6', @group], skip_digest: true do
    json.(@group, :id, :title, :sources, :update_date)
  end
end
