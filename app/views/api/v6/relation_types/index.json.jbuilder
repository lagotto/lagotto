json.meta do
  json.status "ok"
  json.set! :"message-type", "relation_type-list"
  json.set! :"message-version", "6.1.0"
  json.total @relation_types.size
end

json.relation_types @relation_types do |relation_type|
  json.cache! ['v6', relation_type], skip_digest: true do
    json.(relation_type, :id, :title, :inverse_title, :timestamp)
  end
end
