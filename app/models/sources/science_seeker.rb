class ScienceSeeker < Source
  def request_options
    { content_type: 'xml' }
  end

  def get_query_string(work)
    work.doi_escaped
  end

  def get_events(result)
    events = result['feed'] && result.deep_fetch('feed', 'entry') { nil }
    events = [events] if events.is_a?(Hash)
    Array(events).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      timestamp = get_iso8601_from_time(item.fetch("updated", nil))

      { "author" => get_authors([item.fetch('author', {}).fetch('name', "")]),
        "title" => item.fetch('title', nil),
        "container-title" => item.fetch('source', {}).fetch('title', ""),
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => item.fetch("link", {}).fetch("href", nil),
        "type" => 'post' }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=%{query_string}"
  end

  def events_url
    "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=%{query_string}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 1000
  end

  def workers
    config.workers || 3
  end
end
