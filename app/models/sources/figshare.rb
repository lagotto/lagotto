# encoding: UTF-8

class Figshare < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371/

    url % { :doi => work.doi }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    events = Array(result["items"])

    views = get_sum(events, 'stats', 'page_views')
    downloads = get_sum(events, 'stats', 'downloads')
    likes = get_sum(events, 'stats', 'likes')

    total = views + downloads + likes

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(pdf: downloads, html: views, likes: likes, total: total) }
  end

  def config_fields
    [:url]
  end
end
