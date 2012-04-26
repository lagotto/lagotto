require 'doi'

class Connotea < Source

  validates_each :username, :password do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

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
    Rails.logger.error "blogline password #{config.password}"
    config.password
  end
  def password=(value)
    config.password = value
  end

end