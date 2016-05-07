json.meta do
  json.status "ok"
  json.set! :"message-type", "prefix-list"
  json.set! :"message-version", "v7"
  json.total @prefixes.size
end

json.prefixes @prefixes do |prefix|
  json.cache! ['v7', prefix], skip_digest: true do
    json.(prefix, :id, :publisher_id, :registration_agency_id, :timestamp)
  end
end
