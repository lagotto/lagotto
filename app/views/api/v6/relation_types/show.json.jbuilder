json.meta do
  json.status "ok"
  json.message_type "relation_type"
  json.message_version "6.0.0"
end

json.relation_type do
  json.cache! ['v6', @relation_type], skip_digest: true do
    json.(@relation_type, :id, :title, :inverse_title, :update_date)
  end
end
