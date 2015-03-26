class Scopus < Source
  def request_options
    { :headers => { "X-ELS-APIKEY" => api_key, "X-ELS-INSTTOKEN" => insttoken } }
  end

  def get_query_url(work)
    if url.present? && work.doi.present?
      url % { doi: work.doi_escaped }
    end
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    events = result.deep_fetch('search-results', 'entry', 0) { {} }

    if events["link"]
      total = events['citedby-count'].to_i
      link = events["link"].find { |link| link["@ref"] == "scopus-citedby" }
      events_url = link["@href"]

      # store Scopus ID if we haven't done this already
      unless work.scp.present?
        scp = events['dc:identifier']
        work.update_attributes(:scp => scp[10..-1]) if scp.present?
      end
    else
      total = 0
      events_url = nil
    end

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      total: total,
      event_metrics: get_event_metrics(citations: total) }
  end

  def config_fields
    [:url, :api_key, :insttoken]
  end

  def url
    "https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(%{doi})"
  end

  def insttoken
    config.insttoken
  end

  def insttoken=(value)
    config.insttoken = value
  end
end
