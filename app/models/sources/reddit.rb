# encoding: UTF-8

class Reddit < Source
  def parse_data(result, article)
    return result if result[:error]

    events = result.deep_fetch('data', 'children') { [] }

    likes = get_sum(events, 'data', 'score')
    comments = get_sum(events, 'data', 'num_comments')
    total = likes + comments

    events = get_events(events)

    { events: events,
      events_by_day: get_events_by_day(events, article),
      events_by_month: get_events_by_month(events),
      events_url: get_events_url(article),
      event_count: total,
      event_metrics: get_event_metrics(comments: comments, likes: likes, total: total) }
  end

  def get_events(result)
    result.map do |item|
      data = item['data']
      event_time = get_iso8601_from_epoch(data['created_utc'])
      url = data['url']

      { event: data,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_author(data['author']),
          'title' => data.fetch('title') { '' },
          'container-title' => 'Reddit',
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'personal_communication' }
      }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://www.reddit.com/search.json?q=\"%{doi}\"&limit=100"
  end

  def events_url
    config.events_url || "http://www.reddit.com/search?q=\"%{doi}\""
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1800
  end
end
