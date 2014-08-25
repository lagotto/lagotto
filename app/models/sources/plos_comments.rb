# encoding: UTF-8

class PlosComments < Source
  def get_query_url(article)
    return nil unless article.doi =~ /^10.1371/

    url % { :doi => article.doi }
  end

  def parse_data(result, article, options={})
    return result if result[:error]

    events = get_events(result, article)
    replies = get_sum(events, :event, 'totalNumReplies')
    total = events.length + replies

    { events: events,
      events_by_day: get_events_by_day(events, article),
      events_by_month: get_events_by_month(events),
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(comments: events.length, total: total) }
  end

  def get_events(result, article)
    Array(result['data']).map do |item|
      event_time = get_iso8601_from_time(item['created'])

      { event: item,
        event_time: event_time,
        event_url: nil,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_author(item['creatorFormattedName']),
          'title' => item.fetch('title') { '' },
          'container-title' => 'PLOS Comments',
          'issued' => get_date_parts(event_time),
          'url' => article.doi_as_url,
          'type' => 'personal_communication' }
      }
    end
  end

  def config_fields
    [:url]
  end
end
