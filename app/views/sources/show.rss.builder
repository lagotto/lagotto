xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title APP_CONFIG['useragent']
    xml.link sources_url(@source)

    @source.retrieval_statuses.most_cited.each do |retrieval_status|
      xml.item do
        xml.title retrieval_status.article.title
        xml.description pluralize(retrieval_status.event_count, "event") + " for " + @source.display_name
        xml.pubDate retrieval_status.article.published_on.to_time.utc.to_s(:rfc822)
        xml.link "http://dx.doi.org/#{retrieval_status.article.doi}"
        xml.guid retrieval_status.article.uid
      end
    end
  end
end