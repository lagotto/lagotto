json.cache! @status, skip_digest: true do
  json.(@status, :version, :articles_count, :workers_count, :update_date)
  json.set! :status, "ok"
end
