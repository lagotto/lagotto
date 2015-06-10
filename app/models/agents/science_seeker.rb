class ScienceSeeker < Agent
  def request_options
    { content_type: 'xml' }
  end

  def get_query_string(work)
    return {} unless work.doi.present?

    work.doi_escaped
  end

  def get_related_works(result, work)
    related_works = result.fetch('feed', nil) && result.deep_fetch('feed', 'entry') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    Array(related_works).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      timestamp = get_iso8601_from_time(item.fetch("updated", nil))

      { "author" => get_authors([item.fetch('author', {}).fetch('name', "")]),
        "title" => item.fetch('title', nil),
        "container-title" => item.fetch('source', {}).fetch('title', ""),
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => item.fetch("link", {}).fetch("href", nil),
        "type" => 'post',
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "discusses" }] }
    end
  end

  def get_extra(result)
    extra = result['feed'] && result.deep_fetch('feed', 'entry') { nil }
    extra = [extra] if extra.is_a?(Hash)
    Array(extra).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      event_time = get_iso8601_from_time(item["updated"])
      url = item['link']['href']

      { event: item,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_authors([item.fetch('author', {}).fetch('name', "")]),
          'title' => item.fetch('title', ""),
          'container-title' => item.fetch('source', {}).fetch('title', ""),
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'post'
        }
      }
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

  def cron_line
    config.cron_line || "* 7 28 * *"
  end

  def rate_limiting
    config.rate_limiting || 1000
  end
end
