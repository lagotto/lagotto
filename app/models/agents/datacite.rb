class Datacite < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present? && registration_agencies.include?(work.registration_agency)

    url % { doi: work.doi_escaped }
  end

  def get_events_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && events_url.present? && work.doi.present?

    events_url % { doi: work.doi_escaped }
  end

  def get_related_works(result, work)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map do |item|
      doi = item.fetch("doi", nil)
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS.fetch(type, nil) if type

      relation_type = item.fetch("relatedIdentifier", []).reduce(nil) do |sum, i|
        ri = i.split(":",3 )
        sum = ri.last.casecmp(work.doi) == 0 ? ri.first : sum
      end.underscore

      { "pid" => doi_as_url(doi),
        "author" => get_authors(item.fetch('creator', []), reversed: true, sep: ", "),
        "title" => item.fetch("title", []).first.chomp("."),
        "container-title" => item.fetch("journal_title", nil),
        "issued" => get_date_parts_from_parts(item.fetch("publicationYear", nil)),
        "DOI" => doi,
        "type" => type,
        "tracked" => tracked,
        "registration_agency" => "datacite",
        "related_works" => [{ "pid" => work.pid,
                              "source_id" => name,
                              "relation_type_id" => relation_type }] }
    end.compact
  end

  def get_extra(result)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map { |item| { event: item, event_url: "http://doi.org/#{item['doi']}" } }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://search.datacite.org/api?q=relatedIdentifier:%{doi}&fl=doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre,datacentre_symbol,prefix,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json"
  end

  def events_url
    "http://search.datacite.org/ui?q=relatedIdentifier:%{doi}"
  end

  def registration_agencies
    ["crossref", "dataone", "cdl", "github", "bitbucket"]
  end
end
