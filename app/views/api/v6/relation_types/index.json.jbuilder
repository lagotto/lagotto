json.meta do
  json.status "ok"
  json.message_type "relation_type-list"
  json.message_version "6.0.0"
  json.total @relation_types.size
end

json.relation_types @relation_types do |relation_type|
  json.cache! ['v6', relation_type], skip_digest: true do
    json.(relation_type, :id, :title, :inverse_title, :update_date)
  end
end
