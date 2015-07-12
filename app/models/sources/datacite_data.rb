class DataciteData < Source
  # include common methods for DataCite
  include Datacitable

  def get_related_works(result, work)
    related_identifiers = result.deep_fetch('response', 'docs', 0, 'relatedIdentifier') { [] }
    related_identifiers.map do |item|
      raw_relation_type, related_identifier_type, related_identifier = item.split(":",3 )
      next if related_identifier.blank? || related_identifier_type != "DOI"

      relation_type = RelationType.where(inverse_name: raw_relation_type.underscore).pluck(:name).first
      doi = related_identifier.downcase
      metadata = get_metadata(doi, get_doi_ra(doi))

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
end
