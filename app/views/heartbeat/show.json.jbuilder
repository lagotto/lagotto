json.cache! @status, skip_digest: true do
  json.(@status, :version, :works_count, :update_date)
  json.set! :status, "OK"
end
