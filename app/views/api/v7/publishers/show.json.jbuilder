json.meta do
  json.status "ok"
  json.set! :"message-type", "publisher"
  json.set! :"message-version", "v7"
end

json.publisher do
  json.cache! ['v7', @publisher], skip_digest: true do
    json.(@publisher, :id, :title, :other_names, :prefixes, :registration_agency_id, :timestamp)
  end
end
