class NatureOpensearch < Agent
  def get_query_url(work, options = {})
    query_string = get_query_string(work)
    return {} unless query_string.present? && registration_agencies.include?(work.registration_agency)

    start_record = options[:start_record] || 1

    url % { query_string: query_string, start_record: start_record }
  end

  def get_data(work, options={})
    query_url = get_query_url(work, options)
    return query_url.extend Hashie::Extensions::DeepFetch if query_url.is_a?(Hash)

    result = get_result(query_url, options)

    # make sure we return a hash
    result = { 'data' => result } unless result.is_a?(Hash)

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

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    related_works = get_related_works(result, work)
    total = related_works.length
    events_url = total > 0 ? get_events_url(work) : nil

    { works: related_works,
      events: [{
        source_id: name,
        work_id: work.pid,
        total: total,
        events_url: events_url,
        days: get_events_by_day(related_works, work.published_on),
        months: get_events_by_month(related_works) }] }
  end

  def get_related_works(result, work)
    # result.deep_fetch("sru:recordData", "pam:message", "pam:article", "xhtml:head") { nil }
    result.fetch("feed", {}).fetch("entry", []).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      item = item.deep_fetch("sru:recordData", "pam:message", "pam:article", "xhtml:head") { {} }

      doi = item.fetch("prism:doi", nil)
      url = item.fetch("prism:url", nil)
      author_string = item.fetch("authorString", "").chomp(".")
      timestamp = item.fetch("prism:publicationDate", nil)
      timestamp = "#{timestamp}T00:00:00Z"

      { "author" => get_authors(item.fetch("dc:creator", [])),
        "title" => item.fetch("dc:title", ""),
        "container-title" => item.fetch("prism:publicationName", nil),
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "DOI" => doi,
        "URL" => url,
        "type" => "article-journal",
        "tracked" => tracked,
        "registration_agency" => "crossref",
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "cites" }] }
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

  def registration_agencies
    ["datacite", "dataone", "cdl", "github", "bitbucket"]
  end
end
