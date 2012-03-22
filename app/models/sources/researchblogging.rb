
class Researchblogging < Source

  SOURCE_URL = 'http://researchbloggingconnect.com/blogposts'

  def uses_username; true; end
  def uses_password; true; end

  def get_data(article)
    raise(ArgumentError, "#{display_name} configuration requires username & password") \
      if username.blank? or password.blank?

    url = "#{SOURCE_URL}?count=100&article=doi:#{CGI.escape(article.doi)}"

    options = {}
    options[:timeout] = timeout
    options[:username] = username
    options[:password] = password

    get_xml(url, options) do |document|
      citations = []

      document.find("//blogposts/post").each do |post|

        post_string = post.to_s(:encoding => XML::Encoding::UTF_8)
        details = Hash.from_xml(post_string)
        details = details['post']

        citation = {}
        citation[:uri] = details['post_URL']
        citation[:data] = details;

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