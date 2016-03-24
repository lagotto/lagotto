json.meta do
  json.status "ok"
  json.set! :"message-type", "group-list"
  json.set! :"message-version", "v7"
  json.total @groups.size
end

json.groups @groups do |group|
  json.cache! ['v7', group], skip_digest: true do
    json.(group, :id, :title, :sources, :timestamp)
  end
end
