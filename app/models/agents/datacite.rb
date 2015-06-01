class Datacite < Agent
  # include common methods for DataCite
  include Datacitable

  def get_related_works(result, work)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map do |item|
      doi = item.fetch("doi", nil)
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS.fetch(type, nil) if type

      related_identifier = item.fetch("relatedIdentifier", []).reduce(nil) do |sum, i|
        ri = i.split(":",3 )
        sum = ri.last.casecmp(work.doi) == 0 ? ri.first : sum
      end
      relation_type = DATACITE_RELATION_TYPE_TRANSLATIONS.fetch(related_identifier, nil) if related_identifier

      { "author" => get_authors(item.fetch('creator', []), reversed: true, sep: ", "),
        "title" => item.fetch("title", []).first.chomp("."),
        "container-title" => item.fetch("journal_title", nil),
        "issued" => get_date_parts_from_parts(item.fetch("publicationYear", nil)),
        "DOI" => doi,
        "type" => type,
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => relation_type }] }
    end.compact
  end

  def get_extra(result)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map { |item| { event: item, event_url: "http://doi.org/#{item['doi']}" } }
  end

  def url
    "http://search.datacite.org/api?q=relatedIdentifier:%{doi}&fl=doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre,datacentre_symbol,prefix,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json"
  end

  def events_url
    "http://search.datacite.org/ui?q=relatedIdentifier:%{doi}"
  end
end
