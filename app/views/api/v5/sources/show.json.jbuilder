json.error @error

json.data do
  json.cache! ['v5', @source], skip_digest: true do
    json.(@source, :name, :display_name, :group, :description, :update_date, :state, :responses, :error_count, :work_count, :event_count, :status, :by_day, :by_month)
  end
end
