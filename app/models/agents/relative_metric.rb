class RelativeMetric < Agent
  def get_query_url(work)
    return {} unless work.doi =~ /^10.1371/

    url_private % { :doi => work.doi_escaped }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    extra = get_extra(result, work.published_on.year)
    total = extra[:subject_areas].reduce(0) { | sum, subject_area | sum + subject_area[:average_usage].reduce(:+) }

    { events: [{
        source_id: name,
        work_id: work.pid,
        total: total,
        extra: extra }] }
  end

  def get_extra(result, year)
    { start_date: "#{year}-01-01T00:00:00Z",
      end_date: Date.civil(year, -1, -1).strftime("%Y-%m-%dT00:00:00Z"),
      subject_areas: Array(result["rows"]).map do |row|
        { :subject_area => row["value"]["subject_area"], :average_usage => row["value"]["data"] }
      end }
  end

  def config_fields
    [:url_private]
  end
end
