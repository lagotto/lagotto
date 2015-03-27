json.source do
  json.cache! ['v6', @source], skip_digest: true do
    json.(@source, :id, :title, :group, :description, :state, :error_count, :work_count, :event_count, :status, :responses, :by_day, :by_month, :update_date)
  end
end
