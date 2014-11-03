# encoding: UTF-8

class PmcEurope < Source
  def get_query_url(article)
    return nil unless article.get_ids && article.pmid.present?

    url % { :pmid => article.pmid }
  end

  def parse_data(result, article, options={})
    return result if result[:error]

    event_count = result["hitCount"] || 0

    { events: [],
      events_by_day: [],
      events_by_month: [],
      events_url: get_events_url(article),
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def get_events_url(article)
    return nil unless article.pmid.present?

    events_url % { :pmid => article.pmid }
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
