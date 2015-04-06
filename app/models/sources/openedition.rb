class Openedition < Source
  def request_options
    { content_type: 'xml' }
  end

  def get_query_string(work)
    return {} unless work.doi.present?

    work.doi_escaped
  end

  def get_related_works(result, work)
    related_works = result.deep_fetch('RDF', 'item') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    Array(related_works).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("date", nil))

      { "author" => get_authors([item.fetch('creator', "")]),
        "title" => item.fetch('title', nil),
        "container-title" => nil,
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => item.fetch('link', nil),
        "type" => 'post',
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "discusses" }] }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://search.openedition.org/feed.php?op[]=AND&q[]=%{query_string}&field[]=All&pf=Hypotheses.org"
  end

  def events_url
    "http://search.openedition.org/index.php?op[]=AND&q[]=%{query_string}&field[]=All&pf=Hypotheses.org"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 1000
  end
end
