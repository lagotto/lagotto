class RelativeMetric < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi =~ /^10.1371/

    url_private % { :doi => work.doi_escaped }
  end

  def parse_data(result, options={})
    return [result] if result[:error]
    work = Work.where(id: options[:work_id]).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    extra = get_extra(result, work.published_on.year)
    total = extra[:subject_areas].reduce(0) { | sum, subject_area | sum + subject_area[:average_usage].reduce(:+) }

    if total > 0
      subj_id = "http://www.plos.org"
      subj = { "pid" => subj_id,
             "URL" => subj_id,
             "title" => "PLOS",
             "type" => "webpage",
             "issued" => "2012-05-15T16:40:23Z" }
      [{ relation: { "subj_id" => subj_id,
                     "obj_id" => work.pid,
                     "relation_type_id" => "views",
                     "total" => total,
                     "source_id" => source_id },
                     subj: subj }]
    else
      []
    end
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
