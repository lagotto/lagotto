class DataciteImport < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    if only_publishers
      member = Publisher.active.where(registration_agency: "datacite").pluck(:name)
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

  def config_fields
    [:url, :only_publishers]
  end

  def url
    "http://search.datacite.org/api?"
  end
end
