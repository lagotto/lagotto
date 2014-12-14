json.total @publishers.total_entries
json.total_pages (@publishers.total_entries.to_f / @publishers.per_page).ceil
json.page @publishers.total_entries > 0 ? @publishers.current_page : 0
json.error @error

json.data @publishers do |publisher|
  json.cache! ['v5', publisher], skip_digest: true do
    json.(publisher, :name, :title, :other_names, :member_id, :prefixes, :service, :update_date)
  end
end
