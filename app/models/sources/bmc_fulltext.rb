class BmcFulltext < Source
  def get_query_url(work, options = {})
    return {} unless work.doi =~ /^10.1186/

    query_string = get_query_string(work)

    url % { query_string: query_string }
  end

  def get_query_string(work)
    work.doi.presence || work.canonical_url.presence
  end

  def parse_data(result, work, options={})
    return result if result[:error] || result["entries"].nil?

    related_works = get_related_works(result, work)
    events_url = related_works.length > 0 ? get_events_url(work) : nil

    { works: related_works,
      metrics: {
        source: name,
        work: work.pid,
        total: related_works.length,
        events_url: events_url,
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
        "URL" => get_url_from_doi(doi),
        "type" => "article-journal",
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "cites" }] }
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
