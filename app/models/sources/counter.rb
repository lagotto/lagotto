class Counter < Source
  def get_query_url(work)
    return {} unless work.doi =~ /^10.1371\/journal/

    url_private % { :doi => work.doi_escaped }
  end

  def request_options
    { content_type: "xml"}
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    extra = get_extra(result)

    pdf = get_sum(extra, "pdf_views")
    html = get_sum(extra, "html_views")
    xml = get_sum(extra, "xml_views")
    total = pdf + html + xml

    { events: {
        source: name,
        work: work.pid,
        pdf: pdf,
        html: html,
        total: total,
        extra: extra,
        months: get_events_by_month(extra) } }
  end

  def get_extra(result)
    extra = result.deep_fetch('rest', 'response', 'results', 'item') { nil }
    extra = [extra] if extra.is_a?(Hash)
    Array(extra).map do |item|
      { "month" => item.fetch("month", nil),
        "year" => item.fetch("year", nil),
        "pdf_views" => item.fetch("get_pdf", "0"),
        "xml_views" => item.fetch("get_xml", "0"),
        "html_views" => item.fetch("get_document", "0") }
    end
  end

  def get_events_by_month(extra)
    extra.map do |month|
      html = month["html_views"].to_i
      pdf = month["pdf_views"].to_i
      xml = month["xml_views"].to_i

      { month: month["month"].to_i,
        year: month["year"].to_i,
        html: html,
        pdf: pdf,
        total: html + pdf + xml }
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
