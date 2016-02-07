class Openedition < Agent
  def request_options
    { content_type: 'xml' }
  end

  def get_query_string(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present?

    work.doi_escaped
  end

  def get_related_works(result, work)
    related_works = result.deep_fetch('RDF', 'item') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    Array(related_works).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("date", nil))
      url = item.fetch('link', nil)

      { "pid" => url,
        "author" => get_authors([item.fetch('creator', "")]),
        "title" => item.fetch('title', nil),
        "container-title" => nil,
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => 'post',
        "tracked" => tracked,
        "related_works" => [{ "pid" => work.pid,
                              "source_id" => name,
                              "relation_type_id" => "discusses" }] }
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

  def cron_line
    config.cron_line || "* 7 28 * *"
  end

  def rate_limiting
    config.rate_limiting || 1000
  end
end
