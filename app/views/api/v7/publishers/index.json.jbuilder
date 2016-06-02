json.meta do
  json.status "ok"
  json.set! :"message-type", "publisher-list"
  json.set! :"message-version", "v7"
  json.total @publishers.total_entries
  json.total_pages @publishers.per_page > 0 ? @publishers.total_pages : 1
  json.page @publishers.total_entries > 0 ? @publishers.current_page : 1
  json.registration_agencies @registration_agencies
end

json.publishers @publishers do |publisher|
  json.cache! ['v7', publisher], skip_digest: true do
    json.(publisher, :id, :title, :other_names, :prefixes, :registration_agency_id, :timestamp)
  end
end
