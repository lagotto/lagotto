json.meta do
  json.status "ok"
  json.set! :"message-type", "result-list"
  json.set! :"message-version", "v7"
  json.total @results.total_entries
  json.total_pages @results.per_page > 0 ? @results.total_pages : 1
  json.page @results.total_entries > 0 ? @results.current_page : 1
end

json.results @results do |result|
  json.cache! ['v7', result], skip_digest: true do
    json.(result, :source_id, :work_id, :total, :by_month, :by_year, :timestamp)
  end
end
