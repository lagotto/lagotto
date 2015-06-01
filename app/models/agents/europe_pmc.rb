class EuropePmc < Agent
  # include common methods for Europe PMC
  include Pmcable

  def get_query_url(work, options = {})
    return {} unless work.get_ids && work.pmid.present?

    page = options[:page] || 1

    url % { :pmid => work.pmid, page: page }
  end

  def get_events_url(work)
    return nil unless work.pmid.present?

    events_url % { :pmid => work.pmid }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pmid}/citations/%{page}/json"
  end

  def events_url
    "http://europepmc.org/abstract/MED/%{pmid}#fragment-related-citations"
  end

  def rows
    25
  end

  def result_key
    "citation"
  end

  def pmid_key
    "id"
  end

  def container_title_key
    "journalAbbreviation"
  end
end
