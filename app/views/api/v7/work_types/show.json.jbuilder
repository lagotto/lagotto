json.meta do
  json.status "ok"
  json.set! :"message-type", "work_type"
  json.set! :"message-version", "v7"
end

json.work_type do
  json.cache! ['v7', @work_type], skip_digest: true do
    json.(@work_type, :id, :title, :container, :timestamp)
  end
end
