
class Postgenomic < Source

  validates_each :url do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    query_url = get_query_url(article)

    events = get_json(query_url, options).map do |result|
      {:event => result, :event_url => result["url"]}
    end

    {:events => events,
     :events_url => "http://postgenomic.com/paper.php?doi=#{CGI.escape(article.doi)}",
     :event_count => events.length}

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