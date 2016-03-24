json.meta do
  json.status "ok"
  json.set! :"message-type", "months-list"
  json.set! :"message-version", "v7"
  json.total @months.size
end

json.months @months do |month|
  json.cache! ['v7', month], skip_digest: true do
    json.(month, :source_id, :year, :month, :total)
  end
end
