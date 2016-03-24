json.meta do
  json.status "ok"
  json.set! :"message-type", "group"
  json.set! :"message-version", "v7"
end

json.group do
  json.cache! ['v7', @group], skip_digest: true do
    json.(@group, :id, :title, :sources, :timestamp)
  end
end
