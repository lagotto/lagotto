json.meta do
  json.status "ok"
  json.set! :"message-type", "agent"
  json.set! :"message-version", "v7"
end

json.agent do
  json.cache! ['v7', @agent], skip_digest: true do
    json.(@agent, :id, :source_token, :title, :group_id, :description, :state, :responses, :timestamp)
  end
end
