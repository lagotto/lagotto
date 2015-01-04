class PmcEurope < Source
  def get_query_url(work)
    return nil unless url.present? && work.get_ids && work.pmid.present?

    url % { :pmid => work.pmid }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    event_count = result["hitCount"] || 0
    events_url = event_count > 0 ? get_events_url(work) : nil

    { events: [],
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def get_events_url(work)
    return nil unless work.pmid.present?

    events_url % { :pmid => work.pmid }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pmid}/citations/1/json"
  end

  def events_url
    config.events_url || "http://europepmc.org/abstract/MED/%{pmid}#fragment-related-citations"
  end
end
