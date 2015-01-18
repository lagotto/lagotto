json.cache! @status, skip_digest: true do
  json.(@status, :version, :works_count, :works_new_count, :responses_count, :requests_count, :requests_average, :update_date)
end

json.status @process.current_status
