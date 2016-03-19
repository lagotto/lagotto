class Datacite < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present? && registration_agencies.include?(work.registration_agency)

    url % { doi: work.doi_escaped }
  end

  def get_provenance_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && provenance_url.present? && work.doi.present?

    provenance_url % { doi: work.doi_escaped }
  end

  def get_relations_with_related_works(result, work)
    result["response"] ||= {}
    provenance_url = get_provenance_url(work_id: work.id)

    Array(result["response"]["docs"]).map do |item|
      doi = item.fetch("doi", nil)
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS.fetch(type, nil) if type

      relation_type_id = item.fetch("relatedIdentifier", []).reduce(nil) do |sum, i|
        ri = i.split(":",3 )
        sum = ri.last.casecmp(work.doi) == 0 ? ri.first : sum
      end.underscore

      subj = { "pid" => doi_as_url(doi),
               "author" => get_authors(item.fetch('creator', []), reversed: true, sep: ", "),
               "title" => item.fetch("title", []).first.chomp("."),
               "container-title" => item.fetch("publisher", nil),
               "issued" => item.fetch("publicationYear", nil),
               "publisher_id" => item.fetch("datacentre_symbol", nil),
               "DOI" => doi,
               "type" => type,
               "tracked" => tracked,
               "registration_agency" => "datacite" }

      { prefix: subj["DOI"][/^10\.\d{4,5}/],
        relation: { "subj_id" => subj["pid"],
                    "obj_id" => work.pid,
                    "relation_type_id" => relation_type_id,
                    "source_id" => source_id,
                    "publisher_id" => subj["publisher_id"] },
        subj: subj }
    end
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://search.datacite.org/api?q=relatedIdentifier:%{doi}&fl=doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre,datacentre_symbol,prefix,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json"
  end

  def provenance_url
    "http://search.datacite.org/ui?q=relatedIdentifier:%{doi}"
  end

  def registration_agencies
    ["crossref", "dataone", "cdl", "github", "bitbucket"]
  end
end
