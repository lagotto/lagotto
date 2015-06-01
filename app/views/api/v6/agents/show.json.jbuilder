json.meta do
  json.status "ok"
  json.set! :"message-type", "agent"
  json.set! :"message-version", "6.0.0"
end

json.agent do
  json.cache! ['v6', @agent], skip_digest: true do
    json.(@agent, :id, :title, :group_id, :description, :state, :status, :responses, :timestamp)
  end
end
