class NatureOpensearch < Agent
  def get_query_url(options = {})
    query_string = get_query_string(options)
    return {} unless query_string.present?

    start_record = options[:start_record] || 1

    url % { query_string: query_string, start_record: start_record }
  end

  def get_query_string(options = {})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && registration_agencies.include?(work.registration_agency && work.registration_agency.name) && (work.get_url || work.doi.present?)

    [work.doi, work.canonical_url].compact.map { |i| "%22#{i}%22" }.join("+OR+")
  end

  def get_data(options={})
    query_url = get_query_url(options)
    return query_url.extend Hashie::Extensions::DeepFetch if query_url.is_a?(Hash)

    result = get_result(query_url, options)

    # make sure we return a hash
    result = { 'data' => result } unless result.is_a?(Hash)

    total = (result.fetch("feed", {}).fetch("opensearch:totalResults", nil)).to_i

    if total > rows
      # walk through paginated results
      total_pages = (total.to_f / rows).ceil

      (2..total_pages).each do |page|
        options[:start_record] = page * 25 + 1
        query_url = get_query_url(options)
        paged_result = get_result(query_url, options)
        result["feed"]["entry"] = result["feed"]["entry"] | paged_result.fetch("feed", {}).fetch("entry", [])
      end
    end

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def get_relations_with_related_works(result, work)
    provenance_url = get_provenance_url(work_id: work.id)

    result.fetch("feed", {}).fetch("entry", []).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      item = item.deep_fetch("sru:recordData", "pam:message", "pam:article", "xhtml:head") { {} }

      doi = item.fetch("prism:doi", nil)
      subj_id = doi_as_url(doi)
      author_string = item.fetch("authorString", "").chomp(".")
      timestamp = item.fetch("prism:publicationDate", nil)
      timestamp = "#{timestamp}T00:00:00Z"

      { prefix: work.prefix,
        relation: { "subj_id" => subj_id,
                    "obj_id" => work.pid,
                    "relation_type_id" => "cites",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: { "pid" => subj_id,
                "author" => get_authors(item.fetch("dc:creator", [])),
                "title" => item.fetch("dc:title", ""),
                "container-title" => item.fetch("prism:publicationName", nil),
                "issued" => timestamp,
                "DOI" => doi,
                "type" => "article-journal",
                "tracked" => tracked,
                "registration_agency_id" => "crossref" }}
    end
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://www.nature.com/opensearch/request?query=%{query_string}&httpAccept=application/json&startRecord=%{start_record}"
  end

  def provenance_url
    "http://www.nature.com/search?q=%{query_string}"
  end

  def rate_limiting
    config.rate_limiting || 25000
  end

  def rows
    25
  end

  def registration_agencies
    ["datacite", "dataone", "cdl", "github", "bitbucket"]
  end

  def tracked
    config.tracked || true
  end
end
