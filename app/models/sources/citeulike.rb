class Citeulike < Source
  def request_options
    { content_type: 'xml' }
  end

  def response_options
    { metrics: :readers }
  end

  def get_query_url(work)
    return {} unless work.doi.present?

    url % { doi: work.doi_escaped }
  end

  def get_events_url(work)
    if events_url.present? && work.doi.present?
      events_url % { doi: work.doi_escaped }
    end
  end

  def get_related_works(result, work)
    related_works = result["posts"] && result.fetch("posts", {}).fetch("post", [])
    related_works = [related_works] if related_works.is_a?(Hash)
    Array(related_works).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("post_time", nil))
      author = get_authors([item.fetch("post", {}).fetch("username", nil)].reject(&:blank?))

      { "author" => author.presence || nil,
        "title" => "CiteULike bookmark by user #{author} for DOI #{work.doi}",
        "container-title" => "CiteULike",
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => item.fetch("link", {}).fetch("url", nil),
        "type" => "entry",
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "bookmarks" }] }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.citeulike.org/api/posts/for/doi/%{doi}"
  end

  def events_url
    "http://www.citeulike.org/doi/%{doi}"
  end

  def rate_limiting
    config.rate_limiting || 2000
  end
end
