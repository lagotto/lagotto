json.meta do
  json.status "ok"
  json.set! :"message-type", "publisher"
  json.set! :"message-version", "6.0.0"
end

json.publisher do
  json.cache! ['v6', @publisher], skip_digest: true do
    json.(@publisher, :id, :title, :other_names, :prefixes, :timestamp)
  end
end
