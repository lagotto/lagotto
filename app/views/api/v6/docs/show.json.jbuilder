json.meta do
  json.status "ok"
  json.set! :"message-type", "doc"
  json.set! :"message-version", "6.0.0"
end

json.doc do
  json.cache! ['v6', @doc], skip_digest: true do
    json.(@doc, :id, :title, :layout, :content, :update_date)
  end
end
