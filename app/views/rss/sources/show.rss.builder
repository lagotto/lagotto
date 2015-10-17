xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    if @source.nil?
      xml.title "Lagotto: source not found"
      xml.link root_url
    else
      xml.title "Lagotto: most-cited works in #{@source.title}"
      xml.link source_url(@source)

      @events.each do |event|
        xml.item do
          xml.title event.work.title
          xml.description pluralize(event.total, "#{@source.title} event")
          xml.pubDate event.work.published_on.to_time.utc.to_s(:rfc822)
          xml.link event.work.pid
          xml.guid event.work.pid
        end
      end
    end
  end
end
