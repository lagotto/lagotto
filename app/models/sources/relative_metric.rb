class RelativeMetric < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371/

    url % { :doi => work.doi_escaped }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    events = get_events(result, work.published_on.year)

    total = events[:subject_areas].reduce(0) { | sum, subject_area | sum + subject_area[:average_usage].reduce(:+) }

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(total: total) }
  end

  def get_events(result, year)
    { start_date: "#{year}-01-01T00:00:00Z",
      end_date: Date.civil(year, -1, -1).strftime("%Y-%m-%dT00:00:00Z"),
      subject_areas: Array(result["rows"]).map do |row|
        { :subject_area => row["value"]["subject_area"], :average_usage => row["value"]["data"] }
      end }
  end

  def config_fields
    [:url]
  end
end
