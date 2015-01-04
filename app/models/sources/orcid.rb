class Orcid < Source
  def response_options
    { metrics: :shares }
  end

  def get_events(result)
    Array(result.fetch("orcid-search-results", {}).fetch("orcid-search-result", nil)).map do |item|
      event = item.fetch("orcid-profile", {})
      url = event.fetch("orcid-identifier", {}).fetch("uri", nil)

      { event: event,
        event_url: url }
    end
  end

  def config_fields
    [:url]
  end

  def url
    config.url || "http://pub.orcid.org/v1.1/search/orcid-bio/?q=digital-object-ids:\"%{doi}\"&rows=100"
  end

  def events_url
    config.events_url || "https://orcid.org/orcid-search/quick-search/?searchQuery=\"%{doi}\"&rows=100"
  end
end
