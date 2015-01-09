json.cache! @status, skip_digest: true do
  json.(@status, :version, :works_count, :works_last_day_count, :responses_count, :requests_count, :requests_average, :update_date)
end

json.status @status.current_status
