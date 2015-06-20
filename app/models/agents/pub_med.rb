class PubMed < Agent
  def get_query_url(work)
    return {} unless work.get_ids && work.pmid.present?

    url % { :pmid => work.pmid }
  end

  def request_options
    { content_type: 'xml' }
  end

  def get_related_works(result, work)
    related_works = result.deep_fetch('PubMedToPMCcitingformSET', 'REFORM', 'PMCID') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    Array(related_works).map do |item|
      ids = get_persistent_identifiers(item, "pmcid")
      ids = {} unless ids.is_a?(Hash)
      doi = ids.fetch("doi", nil)
      pmid = ids.fetch("pmid", nil)

      if doi.present?
        metadata = get_crossref_metadata(doi)
      else
        metadata = get_pubmed_metadata(pmid)
      end

      if metadata[:error]
        nil
      else
        { "issued" => metadata.fetch("issued", {}),
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
          "related_works" => [{ "related_work" => work.pid,
                                "source" => name,
                                "relation_type" => "cites" }] }
      end
    end.compact
  end

  def get_extra(result)
    extra = result.deep_fetch('PubMedToPMCcitingformSET', 'REFORM', 'PMCID') { nil }
    extra = [extra] if extra.is_a?(Hash)
    Array(extra).map do |item|
      { :event => item,
        :event_url => "http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + item }
    end
  end

  def get_events_url(work)
    if work.pmid.present?
      events_url % { :pmid => work.pmid }
    else
      nil
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pmid}"
  end

  def events_url
    "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=%{pmid}"
  end
end
