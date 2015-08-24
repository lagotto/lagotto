class DataciteData < Agent
  # include common methods for DataCite
  include Datacitable

  def get_query_url(work)
    return {} unless work.doi.present? && registration_agencies.include?(work.registration_agency)

    url % { doi: work.doi_escaped }
  end

  def get_related_works(result, work)
    result.extend Hashie::Extensions::DeepFetch
    related_identifiers = result.deep_fetch('response', 'docs', 0, 'relatedIdentifier') { [] }
    related_identifiers.map do |item|
      raw_relation_type, related_identifier_type, related_identifier = item.split(":",3 )
      next if related_identifier.blank? || related_identifier_type != "DOI"

      relation_type = RelationType.where(inverse_name: raw_relation_type.underscore).pluck(:name).first
      doi = related_identifier.downcase
      registration_agency = get_doi_ra(doi)
      metadata = get_metadata(doi, registration_agency)

      if metadata[:error]
        nil
      else
        { "issued" => metadata.fetch("issued", {}),
          "author" => metadata.fetch("author", []),
          "container-title" => metadata.fetch("container-title", nil),
          "volume" => metadata.fetch("volume", nil),
          "issue" => metadata.fetch("issue", nil),
          "page" => metadata.fetch("page", nil),
          "title" => metadata.fetch("title", nil),
          "DOI" => doi,
          "type" => metadata.fetch("type", nil),
          "tracked" => tracked,
          "publisher_id" => metadata.fetch("publisher_id", nil),
          "registration_agency" => registration_agency,
          "related_works" => [{ "related_work" => work.pid,
                                "source" => name,
                                "relation_type" => relation_type }] }
      end
    end.compact
  end

  def url
    "http://search.datacite.org/api?q=doi:%{doi}&fl=doi,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json"
  end

  def events_url
    "http://search.datacite.org/ui?q=doi:%{doi}"
  end

  def registration_agencies
    ["datacite"]
  end

  def tracked
    config.tracked || true
  end
end
