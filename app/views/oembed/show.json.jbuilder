json.cache! ['oembed', @article], skip_digest: true do
  json.(@article, :type, :version, :width, :height, :provider_name, :provider_url, :title, :html)
  json.url @article.doi_as_url
end
