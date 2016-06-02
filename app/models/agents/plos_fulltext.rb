class PlosFulltext < Agent
  def get_query_url(options = {})
    query_string = get_query_string(options)
    return {} unless query_string.present?

    url % { query_string: query_string }
  end

  def get_provenance_url(options = {})
    query_string = get_query_string(options)
    return {} unless query_string.present?

    provenance_url % { query_string: query_string }
  end

  def get_query_string(options={})
    # don't query if work is PLOS article
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return nil if work.nil? || work.prefix == "10.1371" || !registration_agencies.include?(work.registration_agency && work.registration_agency.name)

    [work.doi, work.canonical_url].compact.map { |i| "everything:%22#{i}%22" }.join("+OR+")
  end

  def get_relations_with_related_works(result, work)
    provenance_url = get_provenance_url(work_id: work.id)

    result.fetch("response", {}).fetch("docs", []).map do |item|
      doi = item.fetch("id", nil)
      pid = doi_as_url(doi)

      { prefix: work.prefix,
        relation: { "subj_id" => pid,
                    "obj_id" => work.pid,
                    "relation_type_id" => "cites",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: { "pid" => pid,
                "author" => get_authors(item.fetch("author_display", [])),
                "title" => item.fetch("title", ""),
                "container-title" => item.fetch("cross_published_journal_name", []).first,
                "issued" => get_iso8601_from_time(item.fetch("publication_date", nil)),
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
    "http://api.plos.org/search?q=%{query_string}&fq=doc_type:full&fl=id,publication_date,title,cross_published_journal_name,author_display&wt=json&rows=1000"
  end

  def provenance_url
    "http://www.plosone.org/search/advanced?unformattedQuery=%{query_string}"
  end

  def registration_agencies
    ["datacite", "dataone", "cdl", "github", "bitbucket"]
  end
end
