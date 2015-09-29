class DataciteImport < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    if only_publishers
      member = Publisher.where(service: "datacite").pluck(:member_symbol)
      datacentre_symbol = member.blank? ? nil : "datacentre_symbol:" + member.join("+OR+")
    else
      datacentre_symbol = nil
    end

    updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    fq = "#{updated} AND has_metadata:true AND is_active:true"
    fq += " AND #{datacentre_symbol}" if datacentre_symbol
    params = { q: "*:*",
               start: offset,
               rows: rows,
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,relatedIdentifier,updated",
               fq: fq,
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def get_works(result)
    # return early if an error occured
    return [] unless result.is_a?(Hash) && result.fetch("response", nil)

    items = result.fetch('response', {}).fetch('docs', nil)
    Array(items).map do |item|
      year = item.fetch("publicationYear", nil).to_i
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS[type] if type
      publisher_symbol = item.fetch("datacentre_symbol", nil)
      publisher_id = publisher_symbol.to_i(36)

      { "author" => get_authors(item.fetch("creator", []), reversed: true, sep: ", "),
        "container-title" => nil,
        "title" => item.fetch("title", []).first,
        "issued" => { "date-parts" => [[year]] },
        "DOI" => item.fetch("doi", nil),
        "publisher_id" => publisher_id,
        "tracked" => tracked,
        "type" => type }
    end
  end

  def config_fields
    [:url, :only_publishers]
  end

  def url
    "http://search.datacite.org/api?"
  end
end
