class DataciteData < Source
  def get_query_url(work)
    return {} unless work.doi.present?

    url % { doi: work.doi_escaped }
  end

  def get_events_url(work)
    if events_url.present? && work.doi.present?
      events_url % { doi: work.doi_escaped }
    end
  end

  def get_related_works(result, work)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map do |item|
      doi = item.fetch("doi", nil)
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS.fetch(type, nil) if type
      related_works = item.fetch("relatedIdentifier", []).map do |r|
        { "related_work" => work.pid,
          "source" => name,
          "relation_type" => "cites" }
      end

      { "author" => get_authors(item.fetch('creator', []), reversed: true, sep: ", "),
        "title" => item.fetch("title", []).first.chomp("."),
        "container-title" => item.fetch("journal_title", nil),
        "issued" => get_date_parts_from_parts(item.fetch("publicationYear", nil)),
        "DOI" => doi,
        "URL" => get_url_from_doi(doi),
        "type" => type,
        "related_works" => related_works }
    end.compact
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://search.datacite.org/api?q=doi:%{doi}&fl=doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre,datacentre_symbol,prefix,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json"
  end

  def events_url
    "http://search.datacite.org/ui?q=doi:%{doi}"
  end
end
