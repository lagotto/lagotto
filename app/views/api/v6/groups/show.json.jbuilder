json.group do
  json.cache! ['v6', @group], skip_digest: true do
    json.(@group, :id, :title, :sources, :update_date)
  end
end
