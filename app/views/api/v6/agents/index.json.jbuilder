json.meta do
  json.status "ok"
  json.set! :"message-type", "agent-list"
  json.set! :"message-version", "6.0.0"
  json.total @agents.size
end

json.agents @agents do |agent|
  json.cache! ['v6', agent], skip_digest: true do
    json.(agent, :id, :source_token, :title, :group_id, :description, :state, :status, :responses, :timestamp)
  end
end
