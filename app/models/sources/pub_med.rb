# encoding: UTF-8

class PubMed < Source
  def get_query_url(work)
    return nil unless url.present? && work.get_ids && work.pmid.present?

    url % { :pmid => work.pmid }
  end

  def request_options
    { content_type: 'xml' }
  end

  def get_events(result)
    events = result.deep_fetch('PubMedToPMCcitingformSET', 'REFORM', 'PMCID') { nil }
    events = [events] if events.is_a?(Hash)
    Array(events).map do |item|
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
    config.url || "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pmid}"
  end

  def events_url
    config.events_url || "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=%{pmid}"
  end
end
