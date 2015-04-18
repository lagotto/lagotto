xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    if @work.nil?
      xml.title "Lagotto: work not found"
      xml.link root_url
    else
      xml.title "Lagotto: related works for work #{@work.pid}"
      xml.link work_url(@work)

      @work.relationships.each do |relationship|
        xml.item do
          xml.title relationship.related_work.title
          xml.description "#{relationship.relation_type.inverse_title} #{@work.pid} via #{relationship.source.title}"
          xml.pubDate relationship.related_work.published_on.to_time.utc.to_s(:rfc822)
          xml.link work_url(relationship.related_work)
          xml.guid relationship.related_work.doi
        end
      end
    end
  end
end
