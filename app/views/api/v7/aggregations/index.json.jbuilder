json.meta do
  json.status "ok"
  json.set! :"message-type", "aggregations-list"
  json.set! :"message-version", "v7"
  json.total @aggregations.total_entries
  json.total_pages @aggregations.per_page > 0 ? @aggregations.total_pages : 1
  json.page @aggregations.total_entries > 0 ? @aggregations.current_page : 1
end

json.aggregations @aggregations do |aggregation|
  json.cache! ['v7', aggregation], skip_digest: true do
    json.(aggregation, :source_id, :work_id, :total, :by_month, :by_year, :timestamp)
  end
end
