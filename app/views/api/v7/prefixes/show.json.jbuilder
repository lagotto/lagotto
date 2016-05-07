json.meta do
  json.status "ok"
  json.set! :"message-type", "prefix"
  json.set! :"message-version", "v7"
end

json.prefix do
  json.cache! ['v7', @prefix], skip_digest: true do
    json.(@prefix, :id, :publisher_id, :registration_agency_id, :timestamp)
  end
end
