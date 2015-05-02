json.meta do
  json.status "ok"
  json.set! :"message-type", "source"
  json.set! :"message-version", "6.0.0"
end

json.source do
  json.cache! ['v6', @source], skip_digest: true do
    json.(@source, :id, :title, :group_id, :description, :state, :error_count, :work_count, :event_count, :status, :responses, :by_day, :by_month, :timestamp)
  end
end
