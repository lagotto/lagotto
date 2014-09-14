xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    if @source.nil?
      xml.title CONFIG[:useragent] + ": source not found"
      xml.link root_url
    else
      xml.title CONFIG[:useragent] + ": most-cited articles in #{@source.display_name}"
      xml.link source_url(@source)

      @retrieval_statuses.each do |retrieval_status|
        xml.item do
          xml.title retrieval_status.article.title
          xml.description pluralize(retrieval_status.event_count, "#{@source.display_name} event")
          xml.pubDate retrieval_status.article.published_on.to_time.utc.to_s(:rfc822)
          xml.link "http://dx.doi.org/#{retrieval_status.article.doi}"
          xml.guid retrieval_status.article.uid
        end
      end
    end
  end
end
