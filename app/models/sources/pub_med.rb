class PubMed < Source
  def get_query_url(work)
    return {} unless work.get_ids && work.pmid.present?

    url % { :pmid => work.pmid }
  end

  def request_options
    { content_type: 'xml' }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    total = work.publisher_id.nil? ? 0 : related_works_count(result)

    { events: {
        source: name,
        work: work.pid,
        total: total,
        extra: get_extra(result) } }
  end

  def related_works_count(result)
    related_works = result.deep_fetch('PubMedToPMCcitingformSET', 'REFORM', 'PMCID') { nil }
    related_works = [related_works] if (related_works.is_a?(Hash) or related_works.is_a?(String))
    related_works.nil? ? 0 : related_works.size
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
