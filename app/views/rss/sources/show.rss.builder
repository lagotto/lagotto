xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    if @source.nil?
      xml.title "Lagotto: source not found"
      xml.link root_url
    else
      xml.title "Lagotto: most-cited works in #{@source.title}"
      xml.link source_url(@source)

      @results.each do |relation|
        xml.item do
          xml.title relation.work.title
          xml.description pluralize(relation.total, "#{@source.title} event")
          xml.pubDate relation.work.published_on.to_time.utc.to_s(:rfc822)
          xml.link relation.work.pid
          xml.guid relation.work.pid
        end
      end
    end
  end
end
