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

  def get_relations_with_related_works(items)
    Array(items).map do |item|
      doi = item.fetch("doi", nil)
      prefix = doi[/^10\.\d{4,5}/]
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

      { prefix: prefix,
        relation: { "subj_id" => subj["pid"],
                    "source_id" => source_id,
                    "publisher_id" => subj["publisher_id"] },
        subj: subj }
    end
  end

  def config_fields
    [:url, :only_publishers]
  end

  def url
    "http://search.datacite.org/api?"
  end
end
