class Wordpress < Source
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
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "discusses" }] }
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
