class EuropePmc < Agent
  # include common methods for Europe PMC
  include Pmcable

  def get_query_url(options = {})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.get_ids && work.pmid.present?

    page = options[:page] || 1

    url % { :pmid => work.pmid, page: page }
  end

  def get_provenance_url(work)
    return nil unless work.pmid.present?

    provenance_url % { :pmid => work.pmid }
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pmid}/citations/%{page}/json"
  end

  def provenance_url
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
