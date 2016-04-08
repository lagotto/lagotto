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
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,nameIdentifier,xml,updated",
               fq: "#{updated} AND has_metadata:true AND is_active:true",
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def get_relations_with_related_works(items)
    Array(items).reduce([]) do |sum, item|
      doi = item.fetch("doi", nil)
      pid = doi_as_url(doi)
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS[type] if type
      publisher_id = item.fetch("datacentre_symbol", nil)

      xml = Base64.decode64(item.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)

      obj = { "pid" => pid,
               "DOI" => doi,
               "author" => get_hashed_authors(authors),
               "title" => item.fetch("title", []).first,
               "container-title" => item.fetch("publisher", nil),
               "issued" => item.fetch("publicationYear", nil),
               "publisher_id" => publisher_id,
               "registration_agency" => "datacite",
               "tracked" => true,
               "type" => type }

      name_identifiers = item.fetch('nameIdentifier', []).select { |id| id =~ /^ORCID:.+/ }
      sum += get_relations(obj, name_identifiers)
    end
  end

  def get_relations(obj, items)
    prefix = obj["DOI"][/^10\.\d{4,5}/]

    Array(items).reduce([]) do |sum, item|
      orcid = item.split(':', 2).last
      orcid = validate_orcid(orcid)

      return sum if orcid.nil?

      sum << { prefix: prefix,
               message_type: "contribution",
               relation: { "subj_id" => orcid_as_url(orcid),
                           "obj_id" => obj["pid"],
                           "source_id" => source_id,
                           "publisher_id" => obj["publisher_id"] },
               obj: obj }
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
