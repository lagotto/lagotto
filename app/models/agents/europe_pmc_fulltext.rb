class EuropePmcFulltext < Agent
  # include common methods for Europe PMC
  include Pmcable

  def get_query_url(options = {})
    query_string = get_query_string(options)
    return {} unless query_string.present?

    page = options[:page] || 1

    url % { query_string: query_string, page: page }
  end

  def get_query_string(options = {})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.get_url && registration_agencies.include?(work.registration_agency && work.registration_agency.name)

    # fulltext search doesn't search in the reference list
    if work.doi.present?
      "%22#{work.doi}%22%20OR%20REF:%22#{work.doi}%22"
    elsif work.canonical_url.present?
      "%22#{work.canonical_url}%22%20OR%20REF:%22#{work.canonical_url}%22"
    else
      nil
    end
  end

  def get_relations_with_related_works(result, work)
    result.fetch("#{result_key}List", {}).fetch(result_key, []).map do |item|
      pmid = item.fetch(pmid_key, nil)
      ids = get_persistent_identifiers(pmid, "pmid")
      ids = {} unless ids.is_a?(Hash)
      doi = ids.fetch("doi", nil)
      pmcid = ids.fetch("pmcid", nil)
      pmcid = pmcid[3..-1] if pmcid
      author_string = item.fetch("authorString", "").chomp(".")
      registration_agency_id = doi.present? ? "crossref" : "pubmed"

      subj_id = doi_as_url(doi)

      { prefix: work.prefix,
        relation: { "subj_id" => subj_id,
                    "obj_id" => work.pid,
                    "relation_type_id" => "cites",
                    "source_id" => source_id },
        subj: { "pid" => doi,
                "author" => get_authors(author_string.split(", "), reversed: true),
                "title" => item.fetch("title", "").chomp("."),
                "container-title" => item.fetch(container_title_key, nil),
                "issued" => item.fetch("pubYear", nil),
                "DOI" => doi,
                "PMID" => pmid,
                "PMCID" => pmcid,
                "type" => "article-journal",
                "tracked" => tracked,
                "registration_agency_id" => registration_agency_id }}
    end
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=%{query_string}&format=json&page=%{page}"
  end

  def provenance_url
    "http://europepmc.org/search?query=%{query_string}"
  end

  def rows
    25
  end

  def registration_agencies
    ["datacite", "dataone", "cdl", "github", "bitbucket"]
  end

  def result_key
    "result"
  end

  def pmid_key
    "pmid"
  end

  def container_title_key
    "journalTitle"
  end
end
