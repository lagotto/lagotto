xml.instruct! :xml, :version => "1.0"
xml.oembed do
  xml.type @work.type
  xml.version @work.version
  xml.width @work.width
  xml.height @work.height
  xml.provider_name @work.provider_name
  xml.provider_url @work.provider_url
  xml.title @work.title
  xml.html @work.html
  xml.url @work.doi_as_url
end
