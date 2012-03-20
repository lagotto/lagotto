require 'doi'

class CrossRef < Source

  def uses_username; true; end
  def uses_password; true; end

  def get_data(article)
    raise(ArgumentError, "Crossref configuration requires username & password") \
      if username.blank? or password.blank?

    url = "http://doi.crossref.org/servlet/getForwardLinks?usr=#{username}&pwd=#{password}&doi=#{CGI.escape(article.doi)}"

    options = {}
    options[:timeout] = timeout

    get_xml(url, options) do |document|

      document.root.namespaces.default_prefix = "x"
      citations = []
      document.find("//x:journal_cite").each do |cite|
        cite_string = cite.to_s(:encoding => XML::Encoding::UTF_8)
        citation = Hash.from_xml(cite_string)
        citation = citation["journal_cite"]

        if !citation["doi"].nil?
          citation["uri"] = DOI::to_url(citation["doi"])
        end
        citations << citation
      end

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => citations,
       :event_count => citations.length,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }
    end
  end

end