class BmcFulltext < Source
  def get_query_url(work, options = {})
    return nil unless work.doi !~ /^10.1186/

    query_string = get_query_string(work)
    return nil unless url.present? && query_string.present?

    url % { query_string: query_string }
  end

  def get_query_string(work)
    work.doi.presence || work.canonical_url.presence
  end

  def parse_data(result, work, options={})
    return result if result[:error] || result["entries"].nil?

    events = get_events(result, work)
    total = events.length
    events_url = total > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: get_events_by_day(events, work),
      events_by_month: get_events_by_month(events),
      events_url: events_url,
      event_count: total,
      event_metrics: get_event_metrics(citations: total) }
  end

  def get_events(result, work)
    result.fetch("entries", []).map do |item|
      event_time = get_iso8601_from_time(item.fetch("published Date", nil))
      # workaround since the "doi" attribute is sometimes empty
      doi = "10.1186/#{item.fetch("arxId")}"
      author = Nokogiri::HTML::fragment(item.fetch("authorNames", ""))
      title = Nokogiri::HTML::fragment(item.fetch("bibliograhyTitle", ""))
      container_title = Nokogiri::HTML::fragment(item.fetch("longCitation", ""))

      { event: item,
        event_time: event_time,
        event_url: "http://dx.doi.org/#{doi}",

        # the rest is CSL (citation style language)
        event_csl: {
          "author" => get_authors(author.at_css("span").text.strip.split(/(?:,|and)/), reversed: true),
          "title" => title.at_css("p").text,
          "container-title" => container_title.at_css("em").text,
          "issued" => get_date_parts(event_time),
          "url" => "http://dx.doi.org/#{doi}",
          "type" => "article-journal" }
      }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.biomedcentral.com/search/results?terms=%{query_string}&format=json"
  end

  def events_url
    "http://www.biomedcentral.com/search/results?terms=%{query_string}"
  end
end
