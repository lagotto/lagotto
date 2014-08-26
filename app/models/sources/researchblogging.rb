# encoding: UTF-8

class Researchblogging < Source
  def request_options
    { content_type: 'xml', username: username, password: password }
  end

  def get_events(result)
    events = result.deep_fetch('blogposts', 'post') { nil }
    events = [events] if events.is_a?(Hash)
    Array(events).map do |item|
      event_time = get_iso8601_from_time(item["published_date"])
      url = item['post_URL']

      { event: item,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_author(item['blogger_name']),
          'title' => item.fetch('post_title') { '' },
          'container-title' => item.fetch('blog_name') { '' },
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'post'
        }
      }
    end
  end

  def config_fields
    [:url, :events_url, :username, :password]
  end

  def url
    config.url || "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{doi}"
  end

  def events_url
    config.events_url || "http://researchblogging.org/post-search/list?article=%{doi}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 2000
  end

  def job_batch_size
    config.job_batch_size || 50
  end

  def workers
    config.workers || 3
  end
end
