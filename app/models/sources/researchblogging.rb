
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
      events = []

      document.find("//blogposts/post").each do |post|

        post_string = post.to_s(:encoding => XML::Encoding::UTF_8)
        event = Hash.from_xml(post_string)
        event = event['post']

        events << {:event => event, :event_url => event['post_URL']}
      end

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => events,
       :event_count => events.length,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }

    end

  end
end