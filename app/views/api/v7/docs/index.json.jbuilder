json.meta do
  json.status "ok"
  json.set! :"message-type", "doc-list"
  json.set! :"message-version", "v7"
  json.total @docs.size
end

json.docs @docs do |doc|
  json.cache! ['v7', doc], skip_digest: true do
    json.(doc, :id, :title, :timestamp)
  end
end
