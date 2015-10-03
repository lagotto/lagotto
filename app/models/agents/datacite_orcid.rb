class DataciteOrcid < Agent
  # include common methods for Import
  include Importable

  # include common methods for DataCite
  include Datacitable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    params = { q: "nameIdentifier:ORCID\\:*",
               start: offset,
               rows: rows,
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,nameIdentifier,xml,updated",
               fq: "#{updated} AND has_metadata:true AND is_active:true",
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def get_related_works(items)
    Array(items).reduce([]) do |sum, item|
      doi = item.fetch("doi")
      pid = "http://doi.org/#{doi}"
      name_identifiers = item.fetch('nameIdentifier', []).select { |id| id =~ /^ORCID:.+/ }

      sum += name_identifiers.map do |related_item|
        orcid = related_item.split(':', 2).last

        { "URL" => "http://orcid.org/#{orcid}",
          "related_works" => [{ "related_work" => pid,
                                "source" => name,
                                "relation_type" => "bookmarks" }] }
      end
    end
  end

  def get_events(items)
    Array(items).map do |item|
      doi = item.fetch("doi", nil)
      pid = "http://doi.org/#{doi}"
      name_identifiers = item.fetch('nameIdentifier', []).select { |id| id =~ /^ORCID:.+/ }

      { source_id: name,
        work_id: pid,
        total: name_identifiers.length }
    end
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
