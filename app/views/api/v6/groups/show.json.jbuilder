json.meta do
  json.status "ok"
  json.set! :"message-type", "group"
  json.set! :"message-version", "6.0.0"
end

json.group do
  json.cache! ['v6', @group], skip_digest: true do
    json.(@group, :id, :title, :sources, :timestamp)
  end
end
