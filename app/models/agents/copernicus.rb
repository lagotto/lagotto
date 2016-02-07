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
    return result if result[:error]

    work = Work.where(id: options.fetch(:work_id, nil)).first

    extra = result.fetch("counter", {})

    pdf = extra.fetch("PdfDownloads", 0)
    html = extra.fetch("AbstractViews", 0)
    total = extra.values.reduce(0) { |sum, x| x.nil? ? sum : sum + x }

    extra = result['data'] ? {} : result

    { events: [{
        source_id: "counter",
        work_id: work.pid,
        pdf: pdf,
        html: html,
        total: total,
        extra: extra }] }
  end

  def config_fields
    [:url_private, :username, :password]
  end
end
