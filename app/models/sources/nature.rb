# encoding: UTF-8

class Nature < Source
  def get_events(result)
    Array(result['data']).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      event_time = get_iso8601_from_time(item['post']['created_at'])
      url = item['post']['url']
      url = "http://#{url}" unless url.start_with?("http://")

      { event: item['post'],
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => '',
          'title' => item.deep_fetch('post', 'title') { '' },
          'container-title' => item.deep_fetch('post', 'blog', 'title') { '' },
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'post' }
      }
    end
  end

  def config_fields
    [:url]
  end

  def url
    "http://blogs.nature.com/posts.json?doi=%{doi}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 5000
  end
end
