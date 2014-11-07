xml.instruct! :xml, :version => "1.0"
xml.oembed do
  xml.type @article.type
  xml.version @article.version
  xml.width @article.width
  xml.height @article.height
  xml.provider_name @article.provider_name
  xml.provider_url @article.provider_url
  xml.title @article.title
  xml.html @article.html
  xml.url @article.doi_as_url
end
