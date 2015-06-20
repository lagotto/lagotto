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

  def get_related_works(result, work)
    result.fetch("#{result_key}List", {}).fetch(result_key, []).map do |item|
      pmid = item.fetch(pmid_key, nil)
      ids = get_persistent_identifiers(pmid, "pmid")
      ids = {} unless ids.is_a?(Hash)
      doi = ids.fetch("doi", nil)
      pmcid = ids.fetch("pmcid", nil)
      pmcid = pmcid[3..-1] if pmcid
      author_string = item.fetch("authorString", "").chomp(".")

      { "author" => get_authors(author_string.split(", "), reversed: true),
        "title" => item.fetch("title", "").chomp("."),
        "container-title" => item.fetch(container_title_key, nil),
        "issued" => get_date_parts_from_parts(item.fetch("pubYear", nil)),
        "DOI" => doi,
        "PMID" => pmid,
        "PMCID" => pmcid,
        "type" => "article-journal",
        "tracked" => tracked,
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "cites" }] }
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
