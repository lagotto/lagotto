require 'doi'

class Connotea < Source

  def get_data(article, options={})
    raise(ArgumentError, "Connotea configuration requires username & password") \
      if config.username.blank? or config.password.blank?

    events_url = nil

    url = "http://www.connotea.org/data/uri/#{DOI::to_url article.doi}"

    get_xml(url, options.merge(:username => config.username, :password => config.password)) do |document|
      citations = []
      document.root.namespaces.default_prefix = 'default'
      document.find("//default:Post").each do |cite|
        uri = cite.find_first("@rdf:about").value
        citations << {:event => uri, :event_url => uri}
        events_url = "http://www.connotea.org/uri/" + uri[uri.rindex('/')+1..-1]
      end
      citations

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => citations,
       :events_url => events_url,
       :event_count => citations.length,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }

    end
  end

end