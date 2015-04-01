json.meta do
  json.status "ok"
  json.message_type "publisher-list"
  json.total @publishers.total_entries
  json.total_pages @publishers.per_page > 0 ? @publishers.total_pages : 1
  json.page @publishers.total_entries > 0 ? @publishers.current_page : 0
end

json.publishers @publishers do |publisher|
  json.cache! ['v6', publisher], skip_digest: true do
    json.(publisher, :id, :title, :other_names, :prefixes, :update_date)
  end
end
