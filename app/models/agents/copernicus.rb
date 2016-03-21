class Copernicus < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi =~ /^10.5194/

    url_private % { :doi => work.doi }
  end

  def request_options
    { username: username, password: password }
  end

  def parse_data(result, options={})
    return [result] if result[:error]

    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    extra = result.fetch("counter", {})
    pdf = extra.fetch("PdfDownloads", 0)
    html = extra.fetch("AbstractViews", 0)

    subj_id = "http://publications.copernicus.org"
    subj = { "pid" => subj_id,
             "URL" => subj_id,
             "title" => "Copernicus Publications",
             "type" => "webpage",
             "issued" => "2012-05-15T16:40:23Z" }

    relations = []
    if pdf > 0
      relations << { prefix: work.prefix,
                     relation: { "subj_id" => subj_id,
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "downloads",
                                 "total" => pdf,
                                 "source_id" => source_id },
                     subj: subj }
    end

    if html > 0
      relations << { prefix: work.prefix,
                     relation: { "subj_id" => subj_id,
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "views",
                                 "total" => html,
                                 "source_id" => source_id },
                     subj: subj }
    end

    relations
  end

  def config_fields
    [:url_private, :username, :password]
  end
end
