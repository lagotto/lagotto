class Wordpress < Agent
  def get_query_string(work)
    return {} unless work.get_url || work.doi.present?

    "%22" + (work.doi_escaped.presence || work.canonical_url.presence) + "%22"
  end

  def get_related_works(result, work)
    result['data'] = nil if result['data'].is_a?(String)
    Array(result.fetch("data", nil)).map do |item|
      timestamp = get_iso8601_from_epoch(item.fetch("epoch_time", nil))

      { "author" => get_authors([item.fetch('author', "")]),
        "title" => item.fetch("title", nil),
        "container-title" => nil,
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => item.fetch("link", nil),
        "type" => 'post',
        "tracked" => tracked,
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "discusses" }] }
    end
  end

  def get_extra(result)
    result['data'] = nil if result['data'].is_a?(String)
    Array(result['data']).map do |item|
      event_time = get_iso8601_from_epoch(item["epoch_time"])
      url = item['link']

      { event: item,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_authors([item.fetch('author', "")]),
          'title' => item.fetch('title') { '' },
          'container-title' => '',
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
    "http://en.search.wordpress.com/?q=%{query_string}&t=post&f=json&size=20"
  end

  def events_url
    "http://en.search.wordpress.com/?q=%{query_string}&t=post"
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1000
  end

  def queue
    config.queue || "low"
  end
end
