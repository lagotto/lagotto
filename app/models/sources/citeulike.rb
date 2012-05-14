
class Citeulike < Source

  validates_each :url do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})

    query_url = get_query_url(article)

    get_xml(query_url, options) do |document|
      events = []

      document.find("//posts/post").each do |post|
        post_string = post.to_s(:encoding => XML::Encoding::UTF_8)
        event = Hash.from_xml(post_string)
        event = event['post']
        events << {:event => event, :event_url => event['link']['url']}
      end

      events_url = "http://www.citeulike.org/doi/#{article.doi}"

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => events,
       :events_url => events_url,
       :event_count => events.length,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

end