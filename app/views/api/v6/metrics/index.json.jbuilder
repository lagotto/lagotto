json.meta do
  json.status "ok"
  json.message_type "metrics-list"
  json.message_version "6.0.0"
  json.total @metrics.total_entries
  json.total_pages @metrics.per_page > 0 ? @metrics.total_pages : 1
  json.page @metrics.total_entries > 0 ? @metrics.current_page : 1
end

json.metrics @metrics do |rs|
  json.cache! ['v6', rs, params[:work_id], params[:work_ids], params[:source_id], params[:publisher_id]], skip_digest: true do
    json.(rs, :source_id, :work_id, :pdf, :html, :readers, :comments, :likes, :total, :events_url, :by_day, :by_month, :by_year, :update_date)
  end
end
