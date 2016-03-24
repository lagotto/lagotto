json.meta do
  json.status "ok"
  json.set! :"message-type", "contributor"
  json.set! :"message-version", "v7"
end

json.contributor do
  json.cache! ['v7', @contributor], skip_digest: true do
    json.(@contributor, :id, :family, :given, :timestamp)
  end
end
