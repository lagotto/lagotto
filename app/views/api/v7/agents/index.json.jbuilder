json.meta do
  json.status "ok"
  json.set! :"message-type", "agent-list"
  json.set! :"message-version", "v7"
  json.total @agents.size
end

json.agents @agents do |agent|
  json.cache! ['v7', agent], skip_digest: true do
    json.(agent, :id, :source_token, :title, :group_id, :description, :state, :responses, :timestamp)
  end
end
