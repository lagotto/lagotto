class Openedition < Source
  def request_options
    { content_type: 'xml' }
  end

  def get_events(result)
    events = result.deep_fetch('RDF', 'item') { nil }
    events = [events] if events.is_a?(Hash)
    Array(events).map do |item|
      { event: item,
        event_time: get_iso8601_from_time(item["date"]),
        event_url: item['link'] }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://search.openedition.org/feed.php?op[]=AND&q[]=%{doi}&field[]=All&pf=Hypotheses.org"
  end

  def events_url
    config.events_url || "http://search.openedition.org/index.php?op[]=AND&q[]=%{doi}&field[]=All&pf=Hypotheses.org"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 1000
  end
end
