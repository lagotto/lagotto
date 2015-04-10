xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    if @work.nil?
      xml.title "Lagotto: work not found"
      xml.link root_url
    else
      xml.title "Lagotto: events for work #{@work.pid}"
      xml.link work_url(@work)

      @work.events.each do |event|
        xml.item do
          xml.title event.work.title
          xml.description "#{event.relation_type.title} #{@work.pid} via #{event.source.title}"
          xml.pubDate event.work.published_on.to_time.utc.to_s(:rfc822)
          xml.link work_url(event.work)
          xml.guid event.work.doi
        end
      end
    end
  end
end
