json.meta do
  json.status "ok"
  json.set! :"message-type", "events-list"
  json.set! :"message-version", "6.0.0"
  json.total @aggregations.total_entries
  json.total_pages @events.per_page > 0 ? @aggregations.total_pages : 1
  json.page @events.total_entries > 0 ? @aggregations.current_page : 1
end

json.events @aggregations do |aggregation|
  json.cache! ['v6', aggregation], skip_digest: true do
    json.(aggregation, :source_id, :work_id, :total, :by_month, :by_year, :timestamp)
  end
end
