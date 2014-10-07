# encoding: UTF-8

class Counter < Source
  def get_query_url(article)
    return nil unless article.doi =~ /^10.1371/

    url % { :doi => article.doi_escaped }
  end

  def request_options
    { content_type: "xml"}
  end

  def parse_data(result, article, options={})
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

  # Format Counter events for all articles as csv
  # Show historical data if options[:format] is used
  # options[:format] can be "html", "pdf" or "combined"
  # options[:month] and options[:year] are the starting month and year, default to last month
  def to_csv(options = {})
    if ["html", "pdf", "xml", "combined"].include? options[:format]
      view = "counter_#{options[:format]}_views"
    else
      view = "counter"
    end

    service_url = "#{CONFIG[:couchdb_url]}_design/reports/_view/#{view}"

    result = get_result(service_url, options.merge(timeout: 1800))
    if result.blank? || result["rows"].blank?
      Alert.create(exception: "", class_name: "Faraday::ResourceNotFound",
                   message: "CouchDB report for Counter could not be retrieved.",
                   source_id: id,
                   status: 404,
                   level: Alert::FATAL)
      return nil
    end

    if view == "counter"
      CSV.generate do |csv|
        csv << [CONFIG[:uid], "html", "pdf", "total"]
        result["rows"].each { |row| csv << [row["key"], row["value"]["html"], row["value"]["pdf"], row["value"]["total"]] }
      end
    else
      dates = date_range(options).map { |date| "#{date[:year]}-#{date[:month]}" }

      CSV.generate do |csv|
        csv << [CONFIG[:uid]] + dates
        result["rows"].each { |row| csv << [row["key"]] + dates.map { |date| row["value"][date] || 0 } }
      end
    end
  end

  def config_fields
    [:url]
  end

  def cron_line
    config.cron_line || "* 4 * * *"
  end
end
