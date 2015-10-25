json.meta do
  json.status "ok"
  json.set! :"message-type", "contributor"
  json.set! :"message-version", "6.0.0"
end

json.contributor do
  json.cache! ['v6', @contributor], skip_digest: true do
    json.(@contributor, :id, :family, :given, :timestamp)
  end
end
