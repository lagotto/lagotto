json.meta do
  json.status "ok"
  json.set! :"message-type", "contributor_role"
  json.set! :"message-version", "v7"
end

json.contributor_role do
  json.cache! ['v7', @contributor_role], skip_digest: true do
    json.(@contributor_role, :id, :title, :description, :image_url, :timestamp)
  end
end
