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
      provenance_url = link["@href"]

      # store Scopus ID if we haven't done this already
      unless work.scp.present?
        scp = extra['dc:identifier']
        work.update_attributes(:scp => scp[10..-1]) if scp.present?
      end
    else
      total = 0
      provenance_url = nil
    end

    relations = []
    if total > 0
      relations << { relation: { "subj_id" => "http://www.scopus.com",
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "cites",
                                 "total" => total,
                                 "provenance_url" => provenance_url,
                                 "source_id" => source_id },
                     subj: { "pid" => "http://www.scopus.com",
                             "URL" => "http://www.scopus.com",
                             "title" => "Scopus",
                             "issued" => "2012-05-15T16:40:23Z" }}
    end

    relations
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
