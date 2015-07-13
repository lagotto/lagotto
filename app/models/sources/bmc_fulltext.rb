class BmcFulltext < Source
  def get_query_url(work, options = {})
    # don't query if work is BMC article
    return {} if work.doi =~ /^10.1186/ && registration_agencies.include?(work.registration_agency)

    query_string = get_query_string(work)
    return {} unless query_string.present?

    url % { query_string: query_string }
  end

  def get_query_string(work)
    work.doi.presence || work.canonical_url.presence
  end

  def parse_data(result, work, options={})
    return result if result[:error] || result["entries"].nil?

    related_works = get_related_works(result, work)
    extra = get_extra(result)
    events_url = related_works.length > 0 ? get_events_url(work) : nil

    { works: related_works,
      events: {
        source: name,
        work: work.pid,
        total: related_works.length,
        events_url: events_url,
        extra: extra,
        days: get_events_by_day(related_works, work),
        months: get_events_by_month(related_works) } }
  end

  def get_related_works(result, work)
    result.fetch("entries", []).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("published Date", nil))
      # workaround since the "doi" attribute is sometimes empty
      doi = "10.1186/#{item.fetch("arxId")}"
      author = Nokogiri::HTML::fragment(item.fetch("authorNames", ""))
      title = Nokogiri::HTML::fragment(item.fetch("bibliograhyTitle", ""))
      container_title = Nokogiri::HTML::fragment(item.fetch("longCitation", ""))

      { "author" => get_authors(author.at_css("span").text.strip.split(/(?:,|and)/), reversed: true),
        "title" => title.at_css("p").text,
        "container-title" => container_title.at_css("em").text,
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "DOI" => doi,
        "type" => "article-journal",
        "tracked" => tracked,
        "registration_agency" => "crossref",
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "cites" }] }
    end
  end

  def get_extra(result)
    result.fetch("entries", []).map do |item|
      event_time = get_iso8601_from_time(item.fetch("published Date", nil))
      # workaround since the "doi" attribute is sometimes empty
      doi = "10.1186/#{item.fetch("arxId")}"
      author = Nokogiri::HTML::fragment(item.fetch("authorNames", ""))
      title = Nokogiri::HTML::fragment(item.fetch("bibliograhyTitle", ""))
      container_title = Nokogiri::HTML::fragment(item.fetch("longCitation", ""))

      { event: item,
        event_time: event_time,
        event_url: "http://doi.org/#{doi}",

        # the rest is CSL (citation style language)
        event_csl: {
          "author" => get_authors(author.at_css("span").text.strip.split(/(?:,|and)/), reversed: true),
          "title" => title.at_css("p").text,
          "container-title" => container_title.at_css("em").text,
          "issued" => get_date_parts(event_time),
          "DOI" => doi,
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

  def registration_agencies
    ["datacite", "dataone","cdl", "github", "bitbucket"]
  end
end
