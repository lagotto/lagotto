
class Bloglines < Source

  validates_each :username, :password do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires username & password") \
      if config.username.blank? or config.password.blank?

    title = article.title.gsub(/<\/?[^>]*>/, "")

    url = "http://www.bloglines.com/search?format=publicapi&apiuser=#{config.username}&apikey=#{config.password}&q=#{CGI.escape(title)}"

    get_xml(url, options) do |document|
      events = []
      document.find("//resultset/result").each do |cite|
        event = {}
        %w[site/name site/url site/feedurl title author abstract url].each do |a|
          first = cite.find_first("#{a}")
          if first
            event[a.gsub('/','_').intern] = first.content
          end
        end
        # Ignore citations of the dx.doi.org URI itself
        events << event \
          unless DOI::from_uri(citation[:url]) == article.doi
      end

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => events,
       :event_count => events.length,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }

    end
  end

  def get_config_fields
    [{:field_name => "username", :field_type => "text_field"},
     {:field_name => "password", :field_type => "password_field"}]
  end

  def username
    config.username
  end
  def username=(value)
    config.username = value
  end

  def password
    config.password
  end
  def password=(value)
    config.password = value
  end
end