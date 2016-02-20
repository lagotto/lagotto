class DataciteRelated < Agent
  # include common methods for Import
  include Importable

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

  def get_relations_with_related_works(items)
    Array(items).reduce([]) do |sum, item|
      doi = item.fetch("doi", nil)
      pid = doi_as_url(doi)
      year = item.fetch("publicationYear", nil).to_i
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS[type] if type
      publisher_id = item.fetch("datacentre_symbol", nil)

      xml = Base64.decode64(item.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)

      subj = { "pid" => pid,
               "DOI" => doi,
               "author" => get_hashed_authors(authors),
               "title" => item.fetch("title", []).first,
               "container-title" => item.fetch("publisher", nil),
               "issued" => { "date-parts" => [[year]] },
               "publisher_id" => publisher_id,
               "registration_agency" => "datacite",
               "tracked" => true,
               "type" => type }

      related_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:DOI:.+/ }
      sum += get_relations(subj, related_identifiers)
    end
  end

  def get_relations(subj, items)
    prefix = subj["DOI"][/^10\.\d{4,5}/]

    Array(items).map do |item|
      raw_relation_type, _related_identifier_type, related_identifier = item.split(':', 3)
      pid = doi_as_url(related_identifier.strip.upcase)

      # find relation_type, default to "is_referenced_by" otherwise
      relation_type_id = RelationType.where(name: raw_relation_type.underscore).pluck(:name).first || 'is_referenced_by'

      { prefix: prefix,
        relation: { "subj_id" => subj["pid"],
                    "obj_id" => pid,
                    "relation_type_id" => relation_type_id,
                    "source_id" => source_id,
                    "publisher_id" => subj["publisher_id"] },
        subj: subj }
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
