
class Researchblogging < Source

  SOURCE_URL = 'http://researchbloggingconnect.com/blogposts'

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires username & password") \
      if config.username.blank? or config.password.blank?

    # TODO why did we set the count to 100?
    url = "#{SOURCE_URL}?count=100&article=doi:#{CGI.escape(article.doi)}"

    get_xml(url, options.merge(:username => config.username, :password => config.password)) do |document|
      events = []

      total_count = document.root.attributes.get_attribute("total_records_found")

      document.find("//blogposts/post").each do |post|

        post_string = post.to_s(:encoding => XML::Encoding::UTF_8)
        event = Hash.from_xml(post_string)
        event = event['post']

        events << {:event => event, :event_url => event['post_URL']}
      end

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => events,
       :event_count => total_count.value,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }

    end

  end
end