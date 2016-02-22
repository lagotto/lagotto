json.meta do
  json.status "ok"
  json.set! :"message-type", "relation_type"
  json.set! :"message-version", "6.1.0"
end

json.relation_type do
  json.cache! ['v6', @relation_type], skip_digest: true do
    json.(@relation_type, :id, :title, :inverse_title, :timestamp)
  end
end
