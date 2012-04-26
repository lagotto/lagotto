require 'doi'

class CrossRef < Source

  validates_each :username, :password do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires username & password") \
      if config.username.blank? or config.password.blank?

    url = "http://doi.crossref.org/servlet/getForwardLinks?usr=#{config.username}&pwd=#{config.password}&doi=#{CGI.escape(article.doi)}"

    get_xml(url, options) do |document|
      events = []
      document.root.namespaces.default_prefix = "x"
      document.find("//x:journal_cite").each do |cite|
        cite_string = cite.to_s(:encoding => XML::Encoding::UTF_8)
        event = Hash.from_xml(cite_string)
        event = event["journal_cite"]

        if !event["doi"].nil?
          url = DOI::to_url(event["doi"])
        end

        events << {:event => event, :event_url => url}
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