json.meta do
  json.status "ok"
  json.set! :"message-type", "contributor-list"
  json.set! :"message-version", "6.0.0"
  json.total @contributors.total_entries
  json.total_pages @contributors.per_page > 0 ? @contributors.total_pages : 1
  json.page @contributors.total_entries > 0 ? @contributors.current_page : 1
end

json.contributors @contributors do |contributor|
  json.cache! ['v6', contributor], skip_digest: true do
    json.(contributor, :id, :family, :given, :timestamp)
  end
end
