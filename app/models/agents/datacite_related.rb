class DataciteRelated < Agent
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
    params = { q: "relatedIdentifier:DOI\\:*",
               start: offset,
               rows: rows,
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,relatedIdentifier,xml,updated",
               fq: "#{updated} AND has_metadata:true AND is_active:true",
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def get_related_works(items)
    Array(items).reduce([]) do |sum, item|
      doi = item.fetch("doi")
      pid = "http://doi.org/#{doi}"
      related_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:DOI:.+/ }

      sum += related_identifiers.map do |related_item|
        raw_relation_type, _related_identifier_type, related_identifier = related_item.split(':', 3)
        doi = related_identifier.strip.upcase

        # find relation_type, default to "references" otherwise
        relation_type = RelationType.where(inverse_name: raw_relation_type.underscore).pluck(:name).first || 'references'

        { "DOI" => doi,
          "related_works" => [{ "related_work" => pid,
                                "source" => name,
                                "relation_type" => relation_type }] }
      end
    end
  end

  def get_events(items)
    Array(items).map do |item|
      doi = item.fetch("doi", nil)
      pid = "http://doi.org/#{doi}"
      related_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:DOI:.+/ }

      { source_id: name,
        work_id: pid,
        total: related_identifiers.length }
    end
  end

  def config_fields
    [:url]
  end

  def url
    "http://search.datacite.org/api?"
  end

  def timeout
    config.timeout || 600
  end

  def job_batch_size
    config.job_batch_size || 200
  end
end
