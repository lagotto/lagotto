class Citeulike < Agent
  def request_options
    { content_type: 'xml' }
  end

  def response_options
    { metrics: :readers }
  end

  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present?

    url % { doi: work.doi_escaped }
  end

  def get_events_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return nil unless events_url.present? && work.present? && work.doi.present?

    events_url % { doi: work.doi_escaped }
  end

  def get_related_works(result, work)
    related_works = result["posts"] && result["posts"].is_a?(Hash) && result.fetch("posts", {}).fetch("post", [])
    related_works = [related_works] if related_works.is_a?(Hash)
    related_works ||= nil
    Array(related_works).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("post_time", nil))
      url = item.fetch("link", {}).fetch("url", nil)
      path = URI.split(url)[5].split("/")
      account = path[1]
      author = path[2]
      url = "http://www.citeulike.org/" + path[1..2].join("/")

      { "pid" => url,
        "author" => get_authors([author]),
        "title" => "CiteULike bookmarks for #{account} #{author}",
        "container-title" => "CiteULike",
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => "entry",
        "tracked" => tracked,
        "related_works" => [{ "pid" => work.pid,
                              "source_id" => name,
                              "relation_type_id" => "bookmarks" }] }
    end
  end

  def get_extra(result)
    extra = result['posts'] && result['posts']['post'].respond_to?("map") && result['posts']['post']
    extra = [extra] if extra.is_a?(Hash)
    extra ||= nil
    Array(extra).map do |item|
      { event: item,
        event_time: get_iso8601_from_time(item["post_time"]),
        event_url: item['link']['url'] }
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

  def queue
    config.queue || "low"
  end
end
