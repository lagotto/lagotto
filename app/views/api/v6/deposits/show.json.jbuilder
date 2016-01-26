json.meta do
  json.status @status || "ok"
  json.set! :"message-type", "deposit"
  json.set! :"message-version", "6.0.0"
end

json.deposit do
  json.cache! ['v6', @deposit], skip_digest: true do
    json.(@deposit, :id, :state, :message_type, :message_action, :message, :source_token, :callback, :timestamp)
  end
end
