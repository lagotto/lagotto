json.meta do
  json.status "ok"
  json.set! :"message-type", "data-exports-list"
  json.set! :"message-version", "6.0.0"
  json.total @data_exports.total_entries
  json.total_pages @data_exports.per_page > 0 ? @data_exports.total_pages : 1
  json.page @data_exports.total_entries > 0 ? @data_exports.current_page : 1
end

json.data_exports @data_exports do |data_export|
  json.cache! ['v6', data_export], skip_digest: true do
    json.(data_export, :url, :type, :started_exporting_at, :finished_exporting_at, :failed_at, :state)
  end
end
