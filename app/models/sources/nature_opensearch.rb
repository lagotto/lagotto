class NatureOpensearch < Source
  def get_query_url(work, options = {})
    return nil unless url.present? && work.get_url

    start_record = options[:start_record] || 1

    url % { query_string: work.query_string, start_record: start_record }
  end

  def get_events_url(work)
    return nil unless events_url.present? && work.get_url

    events_url % { query_string: work.query_string }
  end

  def get_data(work, options={})
    query_url = get_query_url(work, options)
    if query_url.nil?
      result = {}
    else
      result = get_result(query_url, options)
      total = (result.fetch("feed", {}).fetch("opensearch:totalResults", nil)).to_i

      if total > rows
        # walk through paginated results
        total_pages = (total.to_f / rows).ceil

        (2..total_pages).each do |page|
          options[:start_record] = page * 25 + 1
          query_url = get_query_url(work, options)
          paged_result = get_result(query_url, options)
          result["feed"]["entry"] = result["feed"]["entry"] | paged_result.fetch("feed", {}).fetch("entry", [])
        end
      end
    end

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, work, options={})
    return result if result[:error] || result["feed"].nil?

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
    # result.deep_fetch("sru:recordData", "pam:message", "pam:article", "xhtml:head") { nil }
    result.fetch("feed", {}).fetch("entry", []).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      item = item.deep_fetch("sru:recordData", "pam:message", "pam:article", "xhtml:head") { {} }

      doi = item.fetch("prism:doi", nil)
      url = item.fetch("prism:url", nil)
      author_string = item.fetch("authorString", "").chomp(".")

      { event: item,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          "author" => get_authors(item.fetch("dc:creator", [])),
          "title" => item.fetch("dc:title", ""),
          "container-title" => item.fetch("prism:publicationName", nil),
          "issued" => get_date_parts(item.fetch("prism:publicationDate", nil)),
          "doi" => doi,
          "url" => url,
          "type" => "article-journal" }
      }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.nature.com/opensearch/request?query=%{query_string}&httpAccept=application/json&startRecord=%{start_record}"
  end

  def events_url
    "http://www.nature.com/search?q=%{query_string}"
  end

  def rate_limiting
    config.rate_limiting || 25000
  end

  def rows
    25
  end
end
