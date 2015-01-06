json.cache! @status, skip_digest: true do
  json.(@status, :version, :works_count, :works_last_day_count, :responses_count, :requests_count, :update_date)
  json.set! :status, "ok"
end
