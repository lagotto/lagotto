json.meta do
  json.status "ok"
  json.set! :"message-type", "doc"
  json.set! :"message-version", "v7"
end

json.doc do
  json.cache! ['v7', @doc], skip_digest: true do
    json.(@doc, :id, :title, :layout, :content, :timestamp)
  end
end
