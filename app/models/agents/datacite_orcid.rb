class DataciteOrcid < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    params = { q: "nameIdentifier:ORCID\\:*",
               start: offset,
               rows: rows,
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,nameIdentifier,updated",
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
      pid = "http://doi.org/#{doi}"
      name_identifiers = item.fetch('nameIdentifier', [])
      related_works = get_related_works(name_identifiers, pid)

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
          "tracked" => true,
          "type" => type }]

        sum += work + related_works
      end
    end
  end

  def get_related_works(name_identifiers, pid)
    name_identifiers.map do |item|
      name_identifier_type, name_identifier = item.split(':', 2)
      next if name_identifier.blank? || name_identifier_type != "ORCID"

      metadata = get_metadata(name_identifier, "orcid")

      { "author" => metadata.fetch("author", []),
        "title" => metadata.fetch("title", nil),
        "container-title" => metadata.fetch("container-title", nil),
        "issued" => metadata.fetch("issued", {}),
        "URL" => metadata.fetch("URL", nil),
        "type" => metadata.fetch("type", nil),
        "tracked" => false,
        "registration_agency" => "orcid",
        "related_works" => [{ "related_work" => pid,
                              "source" => name,
                              "relation_type" => "bookmarks" }] }
    end.compact
  end

  def config_fields
    [:url]
  end

  def url
    "http://search.datacite.org/api?"
  end

  def cron_line
    config.cron_line || "40 18 * * *"
  end

  def timeout
    config.timeout || 120
  end

  def job_batch_size
    config.job_batch_size || 200
  end
end
