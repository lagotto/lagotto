class DataciteRelated < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    params = { q: "relatedIdentifier:*",
               start: offset,
               rows: rows,
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,relatedIdentifier,updated",
               fq: "#{updated} AND has_metadata:true AND is_active:true",
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def get_works(result)
    # return early if an error occured
    return [] unless result.is_a?(Hash) && result.fetch("response", nil)

    items = result.fetch('response', {}).fetch('docs', nil)
    Array(items).reduce([]) do |sum, item|
      doi = item.fetch("doi", nil)
      pid = "http://doi.org/{doi}"
      related_identifiers = item.fetch('relatedIdentifier', [])
      related_works = get_related_works(related_identifiers, pid)

      if related_works.empty?
        sum
      else
        year = item.fetch("publicationYear", nil).to_i
        type = item.fetch("resourceTypeGeneral", nil)
        type = DATACITE_TYPE_TRANSLATIONS[type] if type
        publisher_symbol = item.fetch("datacentre_symbol", nil)
        publisher_id = publisher_symbol.to_i(36)

        work = [{
          "author" => get_authors(item.fetch("creator", []), reversed: true, sep: ", "),
          "container-title" => nil,
          "title" => item.fetch("title", []).first,
          "issued" => { "date-parts" => [[year]] },
          "DOI" => doi,
          "publisher_id" => publisher_id,
          "registration_agency" => "datacite",
          "tracked" => tracked,
          "type" => type }]

        sum += work + related_works
      end
    end
  end

  def get_related_works(related_identifiers, pid)
    related_identifiers.map do |item|
      raw_relation_type, related_identifier_type, related_identifier = item.split(':', 3)
      next if related_identifier.blank? || related_identifier_type != "DOI"

      relation_type = RelationType.where(inverse_name: raw_relation_type.underscore).pluck(:name).first
      doi = related_identifier.strip.upcase
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
          "related_works" => [{ "related_work" => pid,
                                "source" => name,
                                "relation_type" => relation_type }] }
      end
    end.compact
  end

  def config_fields
    [:url]
  end

  def url
    "http://search.datacite.org/api?"
  end
end
