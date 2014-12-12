xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    if @source.nil?
      xml.title "Lagotto: source not found"
      xml.link root_url
    else
      xml.title "Lagotto: most-cited articles in #{@source.display_name}"
      xml.link source_url(@source)

      @retrieval_statuses.each do |retrieval_status|
        xml.item do
          xml.title retrieval_status.work.title
          xml.description pluralize(retrieval_status.event_count, "#{@source.display_name} event")
          xml.pubDate retrieval_status.work.published_on.to_time.utc.to_s(:rfc822)
          xml.link "http://dx.doi.org/#{retrieval_status.work.doi}"
          xml.guid retrieval_status.work.doi
        end
      end
    end
  end
end
