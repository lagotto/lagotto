json.meta do
  json.status "ok"
  json.set! :"message-type", "relation_type"
  json.set! :"message-version", "v7"
end

json.relation_type do
  json.cache! ['v7', @relation_type], skip_digest: true do
    json.(@relation_type, :id, :title, :inverse_title, :timestamp)
  end
end
