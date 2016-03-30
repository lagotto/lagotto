class Counter < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi =~ /^10.1371\/journal/

    url_private % { :doi => work.doi_escaped }
  end

  def request_options
    { content_type: "xml"}
  end

  def parse_data(result, options={})
    return [result] if result[:error]

    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    items = result.deep_fetch('rest', 'response', 'results', 'item') { nil }
    items = [items] if items.is_a?(Hash)

    Array(items).reduce([]) do |sum, item|
      month = item.fetch("month", nil)
      year = item.fetch("year", nil)
      views = item.fetch("get_document", 0).to_i
      downloads = item.fetch("get_pdf", 0).to_i

      return sum if month.nil? || year.nil? || (views + downloads == 0)

      subj_date = get_date_from_parts(year, month, 1)
      subj_id = "http://www.plos.org/#{year}/#{month}"
      subj = { "pid" => subj_id,
               "URL" => "http://www.plos.org",
               "title" => "PLOS",
               "type" => "webpage",
               "issued" => subj_date }

      if views > 0
        sum << { prefix: work.prefix,
                 occurred_at: subj_date,
                 relation: { "subj_id" => subj_id,
                             "obj_id" => work.pid,
                             "relation_type_id" => "views",
                             "total" => views,
                             "source_id" => "counter_html" },
                 subj: subj }
      end

      if downloads > 0
        sum << { prefix: work.prefix,
                 occurred_at: subj_date,
                 relation: { "subj_id" => subj_id,
                             "obj_id" => work.pid,
                             "relation_type_id" => "downloads",
                             "total" => downloads,
                             "source_id" => "counter_pdf" },
                 subj: subj }
      end
    end
  end

  def config_fields
    [:url_private]
  end

  def cron_line
    config.cron_line || "* 4 * * *"
  end

  def queue
    config.queue || "high"
  end
end
