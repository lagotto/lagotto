class PlosComments < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371\/journal/

    url % { :doi => work.doi }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    events = get_events(result, work)
    replies = get_sum(events, :event, 'totalNumReplies')
    total = events.length + replies

    { events: events,
      events_by_day: get_events_by_day(events, work),
      events_by_month: get_events_by_month(events),
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(comments: events.length, total: total) }
  end

  def get_events(result, work)
    Array(result['data']).map do |item|
      event_time = get_iso8601_from_time(item['created'])

      { event: item,
        event_time: event_time,
        event_url: nil,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_authors([item.fetch('creatorFormattedName', "")]),
          'title' => item.fetch('title', ""),
          'container-title' => 'PLOS Comments',
          'issued' => get_date_parts(event_time),
          'url' => work.doi_as_url,
          'type' => 'personal_communication' }
      }
    end
  end

  def config_fields
    [:url]
  end
end
