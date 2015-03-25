class PlosComments < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371\/journal/

    url_private % { :doi => work.doi }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    events = get_events(result, work)
    replies = get_sum(result.fetch('data', []), 'totalNumReplies')
    total = events.length + replies

    { events: events,
      events_by_day: get_events_by_day(events, work),
      events_by_month: get_events_by_month(events),
      events_url: nil,
      comments: events.length,
      total: total,
      event_metrics: get_event_metrics(comments: events.length, total: total),
      extra: nil }
  end

  def get_events(result, work)
    Array(result['data']).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("created", nil))

      { "author" => get_authors([item.fetch('creatorFormattedName', "")]),
        "title" => item.fetch('title', nil),
        "container-title" => 'PLOS Comments',
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => work.doi_as_url,
        "type" => 'personal_communication' }
    end
  end

  def config_fields
    [:url_private]
  end
end
