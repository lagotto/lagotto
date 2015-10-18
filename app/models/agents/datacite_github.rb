class DataciteGithub < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    params = { q: "relatedIdentifier:URL\\:https\\:\\/\\/github.com*",
               start: offset,
               rows: rows,
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,relatedIdentifier,xml,updated",
               fq: "#{updated} AND has_metadata:true AND is_active:true",
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def get_works(items)
    Array(items).map do |item|
      doi = item.fetch("doi", nil)
      pid = doi_as_url(doi)
      year = item.fetch("publicationYear", nil).to_i
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS[type] if type
      publisher_symbol = item.fetch("datacentre_symbol", nil)
      publisher_id = publisher_symbol.present? ? publisher_symbol.to_i(36) : nil

      xml = Base64.decode64(item.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)

      related_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:URL:https:\/\/github.com.+/ }
      related_works = related_identifiers.reduce([]) { |sum, work| sum + get_related_works(work) }

      { "pid" => pid,
        "DOI" => doi,
        "author" => get_hashed_authors(authors),
        "container-title" => nil,
        "title" => item.fetch("title", []).first,
        "issued" => { "date-parts" => [[year]] },
        "publisher_id" => publisher_id,
        "registration_agency" => "datacite",
        "tracked" => true,
        "type" => type,
        "related_works" => related_works }
    end
  end

  def get_related_works(work)
    raw_relation_type, _related_identifier_type, related_identifier = work.split(':', 3)

    # find relation_type, default to "is_referenced_by" otherwise
    relation_type = RelationType.where(name: raw_relation_type.underscore).pluck(:name).first || 'is_referenced_by'

    # get parent repo
    # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
    full_name = URI.parse(related_identifier).path[1..-1]
    owner, repo, _tail = full_name.split('/', 3)
    owner_url = "https://github.com/#{owner}"
    repo_url = "https://github.com/#{owner}/#{repo}"

    owner_metadata = { "pid" => owner_url,
                       "source_id" => name,
                       "relation_type_id" => "is_compiled_by" }
    repo_metadata = { "pid" => repo_url,
                      "source_id" => name,
                      "relation_type_id" => "is_part_of",
                      "related_works" => [owner_metadata] }
    release_metadata = { "pid" => related_identifier,
                         "source_id" => name,
                         "relation_type_id" => relation_type,
                         "related_works" => [repo_metadata] }
    [release_metadata, repo_metadata]
  end

  def get_events(items)
    Array(items).map do |item|
      pid = doi_as_url(item.fetch("doi"))
      related_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:URL:https:\/\/github.com.+/ }

      { source_id: name,
        work_id: pid,
        total: related_identifiers.length }
    end
  end

  def config_fields
    [:url, :personal_access_token]
  end

  def url
    "http://search.datacite.org/api?"
  end

  # More info at https://github.com/blog/1509-personal-api-tokens
  def personal_access_token
    config.personal_access_token
  end

  def personal_access_token=(value)
    config.personal_access_token = value
  end

  def rate_limiting
    config.rate_limiting || 5000
  end

  def timeout
    config.timeout || 600
  end

  def job_batch_size
    config.job_batch_size || 1000
  end
end
