class Scopus < Agent
  def request_options
    { :headers => { "X-ELS-APIKEY" => api_key, "X-ELS-INSTTOKEN" => insttoken } }
  end

  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present?

    url % { doi: work.doi_escaped }
  end

  def parse_data(result, options={})
    return result if result[:error]

    extra = result.deep_fetch('search-results', 'entry', 0) { {} }

    work = Work.where(id: options.fetch(:work_id, nil)).first

    if extra["link"]
      total = extra['citedby-count'].to_i
      link = extra["link"].find { |link| link["@ref"] == "scopus-citedby" }
      events_url = link["@href"]

      # store Scopus ID if we haven't done this already
      unless work.scp.present?
        scp = extra['dc:identifier']
        work.update_attributes(:scp => scp[10..-1]) if scp.present?
      end
    else
      total = 0
      events_url = nil
    end

    { events: [{
        source_id: name,
        work_id: work.pid,
        total: total,
        events_url: events_url,
        extra: extra }] }
  end

  def config_fields
    [:url, :api_key, :insttoken]
  end

  def url
    "https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(%{doi})"
  end

  def insttoken
    config.insttoken
  end

  def insttoken=(value)
    config.insttoken = value
  end
end
