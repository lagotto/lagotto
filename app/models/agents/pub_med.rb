class PubMed < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.get_ids && work.pmid.present?

    url % { :pmid => work.pmid }
  end

  def get_provenance_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.pmid.present?

    provenance_url % { :pmid => work.pmid }
  end

  def request_options
    { content_type: 'xml' }
  end

  def get_relations_with_related_works(result, work)
    related_works = result.deep_fetch('PubMedToPMCcitingformSET', 'REFORM', 'PMCID') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    provenance_url = get_provenance_url(work_id: work.id)

    Array(related_works).map do |item|
      ids = get_persistent_identifiers(item, "pmcid")
      ids = {} unless ids.is_a?(Hash)
      doi = ids.fetch("doi", nil)
      pmid = ids.fetch("pmid", nil)

      if doi.present?
        metadata = get_metadata(doi, "crossref")
        registration_agency = "crossref"
        pid = doi_as_url(doi)
      else
        metadata = get_metadata(pmid, "pubmed")
        registration_agency = "pubmed"
        pid = pmid_as_url(pmid)
      end

      if metadata[:error]
        nil
      else
        { prefix: work.prefix,
          relation: { "subj_id" => pid,
                      "obj_id" => work.pid,
                      "relation_type_id" => "cites",
                      "provenance_url" => provenance_url,
                      "source_id" => source_id },
          subj: { "pid" => pid,
                  "issued" => metadata.fetch("issued", {}),
                  "author" => metadata.fetch("author", []),
                  "container-title" => metadata.fetch("container-title", nil),
                  "volume" => metadata.fetch("volume", nil),
                  "issue" => metadata.fetch("issue", nil),
                  "page" => metadata.fetch("page", nil),
                  "title" => metadata.fetch("title", nil),
                  "DOI" => doi,
                  "PMID" => pmid,
                  "PMCID" => item,
                  "type" => metadata.fetch("type", nil),
                  "tracked" => tracked,
                  "publisher_id" => metadata.fetch("publisher_id", nil),
                  "registration_agency_id" => registration_agency }}
      end
    end.compact
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://www.ncbi.nlm.nih.gov/pmc/utils/entrez2pmcciting.cgi?view=xml&id=%{pmid}"
  end

  def provenance_url
    "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=%{pmid}"
  end
end
