class Nature < Source
  def get_query_string(work)
    work.doi_escaped
  end

  def get_events(result)
    Array(result['data']).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      timestamp = get_iso8601_from_time(item.fetch("post", {}).fetch("created_at", nil))
      url = item.fetch("post", {}).fetch("url", nil)
      url = "http://#{url}" unless url.blank? || url.start_with?("http://")

      { "author" => nil,
        "title" => item.deep_fetch('post', 'title') { '' },
        "container-title" => item.deep_fetch('post', 'blog', 'title') { '' },
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => 'post' }
    end
  end

  def config_fields
    [:url]
  end

  def url
    "http://blogs.nature.com/posts.json?doi=%{query_string}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 5000
  end
end
