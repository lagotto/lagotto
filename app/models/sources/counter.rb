# encoding: UTF-8

class Counter < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371/

    url_private % { :doi => work.doi_escaped }
  end

  def request_options
    { content_type: "xml"}
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    events = get_events(result)

    pdf = get_sum(events, :pdf_views)
    html = get_sum(events, :html_views)
    xml = get_sum(events, :xml_views)
    total = pdf + html + xml

    { events: events,
      events_by_day: [],
      events_by_month: get_events_by_month(events),
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(pdf: pdf, html: html, total: total) }
  end

  def get_events(result)
    events = result.deep_fetch('rest', 'response', 'results', 'item') { nil }
    events = [events] if events.is_a?(Hash)
    Array(events).map do |item|
      { month: item['month'],
        year: item['year'],
        pdf_views: item.fetch('get_pdf') { 0 },
        xml_views: item.fetch('get_xml') { 0 },
        html_views: item.fetch('get_document') { 0 } }
    end
  end

  def get_events_by_month(events)
    events.map do |event|
      { month: event[:month].to_i,
        year: event[:year].to_i,
        html: event[:html_views].to_i,
        pdf: event[:pdf_views].to_i }
    end
  end

  def config_fields
    [:url_private]
  end

  def cron_line
    config.cron_line || "* 4 * * *"
  end
end
