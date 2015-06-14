xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    if @source.nil?
      xml.title "Lagotto: source not found"
      xml.link root_url
    else
      xml.title "Lagotto: most-cited works in #{@source.title}"
      xml.link source_url(@source)

      @retrieval_statuses.each do |retrieval_status|
        xml.item do
          xml.title retrieval_status.work.title
          xml.description pluralize(retrieval_status.total, "#{@source.title} event")
          xml.pubDate retrieval_status.work.published_on.to_time.utc.to_s(:rfc822)
          xml.link retrieval_status.work.url
          xml.guid retrieval_status.work.pid
        end
      end
    end
  end
end
