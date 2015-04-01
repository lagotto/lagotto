json.meta do
  json.status "ok"
  json.message_type "metrics-list"
  json.message_version "6.0.0"
  json.total @retrieval_statuses.total_entries
  json.total_pages @retrieval_statuses.per_page > 0 ? @retrieval_statuses.total_pages : 1
  json.page @retrieval_statuses.total_entries > 0 ? @retrieval_statuses.current_page : 0
end

json.metrics @retrieval_statuses do |rs|
  json.cache! ['v6', rs, params[:work_id], params[:source_id]], skip_digest: true do
    json.(rs, :source_id, :work_id, :html, :pdf, :readers, :comments, :likes, :total, :events_url, :by_day, :by_month, :by_year, :update_date)
  end
end
