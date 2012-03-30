
class Bloglines < Source

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires username & password") \
      if config.username.blank? or config.password.blank?

    title = article.title.gsub(/<\/?[^>]*>/, "")

    url = "http://www.bloglines.com/search?format=publicapi&apiuser=#{config.username}&apikey=#{config.password}&q=#{CGI.escape(title)}"

    get_xml(url, options) do |document|
      citations = []
      document.find("//resultset/result").each do |cite|
        citation = {}
        %w[site/name site/url site/feedurl title author abstract url].each do |a|
          first = cite.find_first("#{a}")
          if first
            citation[a.gsub('/','_').intern] = first.content
          end
        end
        # Ignore citations of the dx.doi.org URI itself
        citations << citation \
          unless DOI::from_uri(citation[:url]) == article.doi
      end

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => citations,
       :event_count => citations.length,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }

    end
  end
end