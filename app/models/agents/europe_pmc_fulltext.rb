class EuropePmcFulltext < Agent
  # include common methods for Europe PMC
  include Pmcable

  def get_query_url(work, options = {})
    return {} unless work.get_url

    query_string = get_query_string(work)
    return {} unless query_string.present?

    page = options[:page] || 1

    url % { query_string: query_string, page: page }
  end

  def get_query_string(work)
    # fulltext search doesn't search in the reference list
    if work.doi.present?
      "%22#{work.doi}%22%20OR%20REF:%22#{work.doi}%22"
    elsif work.canonical_url.present?
      "%22#{work.canonical_url}%22%20OR%20REF:%22#{work.canonical_url}%22"
    else
      nil
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=%{query_string}&format=json&page=%{page}"
  end

  def events_url
    "http://europepmc.org/search?query=%{query_string}"
  end

  def rows
    25
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
