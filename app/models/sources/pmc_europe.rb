class PmcEurope < Source
  def get_query_url(work, options = {})
    return nil unless url.present? && work.get_ids && work.pmid.present?

    page = options[:page] || 1

    url % { :pmid => work.pmid, page: page }
  end

  def get_data(work, options={})
    query_url = get_query_url(work, options)
    if query_url.nil?
      result = {}
    else
      result = get_result(query_url, options)
      total = (result.fetch("hitCount", nil)).to_i

      if total > rows
        # walk through paginated results
        total_pages = (total.to_f / rows).ceil

        (2..total_pages).each do |page|
          options[:page] = page
          query_url = get_query_url(work, options)
          paged_result = get_result(query_url, options)
          result["citationList"]["citation"] = result["citationList"]["citation"] | paged_result.fetch("citationList", {}).fetch("citation", [])
        end
      end
    end

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, work, options={})
    return result if result[:error] || result["citationList"].nil?

    events = get_events(result, work)
    total = events.length
    events_url = total > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      event_count: total,
      event_metrics: get_event_metrics(citations: total) }
  end

  def get_events(result, work)
    result.fetch("citationList", {}).fetch("citation", []).map do |item|
      pmid = item.fetch("id", nil)
      url = "http://europepmc.org/abstract/MED/#{pmid}"
      author_string = item.fetch("authorString", "").chomp(".")

      { event: item,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          "author" => get_authors(author_string.split(", "), reversed: true),
          "title" => item.fetch("title", "").chomp("."),
          "container-title" => item.fetch("journalAbbreviation", nil),
          "issued" => get_date_parts_from_parts(item.fetch("pubYear", nil)),
          "pmid" => pmid,
          "url" => url,
          "type" => "article-journal" }
      }
    end
  end

  def get_events_url(work)
    return nil unless work.pmid.present?

    events_url % { :pmid => work.pmid }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pmid}/citations/%{page}/json"
  end

  def events_url
    "http://europepmc.org/abstract/MED/%{pmid}#fragment-related-citations"
  end

  def rows
    25
  end
end
