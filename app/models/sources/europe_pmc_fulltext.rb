class EuropePmcFulltext < Source
  def get_query_url(work, options = {})
    return nil unless work.get_url

    query_string = get_query_string(work)
    return nil unless url.present? && query_string.present?

    page = options[:page] || 1

    url % { query_string: query_string, page: page }
  end

  def get_events_url(work)
    query_string = get_query_string(work)
    return nil unless events_url.present? && query_string.present?

    events_url % { query_string: query_string }
  end

  def get_query_string(work)
    # fulltext search doesn't search in the reference list
    if work.doi.present?
      "%22#{work.doi}%22%20OR%20REF:%22#{work.doi}%22"
    elsif work.canonical_url.present?
      "%22#{work.canonical_url}%22%20OR%20REF:%22#{work.canonical_url}%22"
    else
      nil
    end
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
          result["resultList"]["result"] = result["resultList"]["result"] | paged_result.fetch("resultList", {}).fetch("result", [])
        end
      end
    end

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, work, options={})
    return result if result[:error] || result["resultList"].nil?

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
    result.fetch("resultList", {}).fetch("result", []).map do |item|
      doi = item.fetch("doi", nil)
      pmid = item.fetch("pmid", nil)
      url = doi ? "http://dx.doi.org/#{doi}" : "http://europepmc.org/abstract/MED/#{pmid}"
      author_string = item.fetch("authorString", "").chomp(".")

      { event: item,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          "author" => get_authors(author_string.split(", "), reversed: true),
          "title" => item.fetch("title", "").chomp("."),
          "container-title" => item.fetch("journalTitle", nil),
          "issued" => get_date_parts_from_parts(item.fetch("pubYear", nil)),
          "doi" => doi,
          "pmid" => pmid,
          "url" => url,
          "type" => "article-journal" }
      }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=%{query_string}&format=json&page=%{page}"
  end

  def events_url
    config.events_url || "http://europepmc.org/search?query=%{query_string}"
  end

  def rows
    25
  end
end
