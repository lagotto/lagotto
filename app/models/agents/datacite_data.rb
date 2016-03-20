class DataciteData < Agent
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
    result.extend Hashie::Extensions::DeepFetch
    related_identifiers = result.deep_fetch('response', 'docs', 0, 'relatedIdentifier') { [] }
    provenance_url = get_provenance_url(work_id: work.id)

    related_identifiers.map do |item|
      raw_relation_type, related_identifier_type, related_identifier = item.split(":",3 )
      next if related_identifier.blank? || related_identifier_type != "DOI"

      doi = related_identifier.upcase
      registration_agency = get_doi_ra(doi)
      metadata = get_metadata(doi, registration_agency)

      if metadata[:error]
        nil
      else
        obj = { "pid" => doi_as_url(doi),
                 "author" => metadata.fetch("author", []),
                 "title" => metadata.fetch("title", nil),
                 "container-title" => metadata.fetch("container-title", nil),
                 "issued" => metadata.fetch("issued", {}),
                 "volume" => metadata.fetch("volume", nil),
                 "issue" => metadata.fetch("issue", nil),
                 "page" => metadata.fetch("page", nil),
                 "DOI" => doi,
                 "type" => metadata.fetch("type", nil),
                 "tracked" => tracked,
                 "publisher_id" => metadata.fetch("publisher_id", nil),
                 "registration_agency" => registration_agency }

      { prefix: work.doi[/^10\.\d{4,5}/],
        relation: { "subj_id" => work.pid,
                    "obj_id" => obj["pid"],
                    "relation_type_id" => raw_relation_type.underscore,
                    "source_id" => source_id,
                    "publisher_id" => obj["publisher_id"] },
        obj: obj }
      end
    end.compact
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://search.datacite.org/api?q=doi:%{doi}&fl=doi,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json"
  end

  def provenance_url
    "http://search.datacite.org/ui?q=doi:%{doi}"
  end

  def registration_agencies
    ["datacite"]
  end

  def tracked
    config.tracked || true
  end
end
