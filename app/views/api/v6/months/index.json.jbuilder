json.meta do
  json.status "ok"
  json.set! :"message-type", "months-list"
  json.set! :"message-version", "6.0.0"
  json.total @months.size
end

json.months @months do |month|
  json.cache! ['v6', month], skip_digest: true do
    json.(month, :source_id, :year, :month, :total)
  end
end
