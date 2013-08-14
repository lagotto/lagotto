xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @error_message.public_message
    xml.link sources_url
  end
end
