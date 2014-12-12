json.cache! ['oembed', @work], skip_digest: true do
  json.(@work, :type, :version, :width, :height, :provider_name, :provider_url, :title, :html)
  json.url @work.doi_as_url
end
