json.meta do
  json.total @publishers.total_entries
  json.total_pages (@publishers.total_entries.to_f / @publishers.per_page).ceil
  json.page @publishers.total_entries > 0 ? @publishers.current_page : 0
end

json.publishers @publishers do |publisher|
  json.cache! ['v6', publisher], skip_digest: true do
    json.(publisher, :id, :title, :other_names, :prefixes, :update_date)
  end
end
