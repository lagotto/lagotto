json.meta do
  json.status "ok"
  json.message_type "doc-list"
  json.message_version "6.0.0"
  json.total @docs.size
end

json.docs @docs do |doc|
  json.cache! ['v6', @doc], skip_digest: true do
    json.(doc, :id, :title, :update_date)
  end
end
