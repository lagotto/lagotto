module Metadatable
  extend ActiveSupport::Concern

  included do
    require 'cirneco'

    def get_metadata(id, service, options = {})
      metadata = case service
        when "crossref" then get_crossref_metadata(id, options = {})
        when "datacite" then get_datacite_metadata(id, options = {})
        when "pubmed" then get_pubmed_metadata(id, options = {})
        when "orcid" then get_orcid_metadata(id, options = {})
        when "github" then get_github_metadata(id, options = {})
        when "github_owner" then get_github_owner_metadata(id, options = {})
        when "github_release" then get_github_release_metadata(id, options = {})
      end

      # Default values if it was recognised but items were missing. This can happen with missing upstream metadata.
      if metadata

        if !metadata[:error]
          metadata["title"] = "(:unas)" if metadata["title"].blank?
          metadata["issued"] = "0000" if metadata["issued"].blank?
        end

        metadata
      else
        { error: 'Resource not found.', status: 404 }
      end
    end

    def get_crossref_metadata(doi, options = {})
      return {} if doi.blank?

      url = "https://api.crossref.org/works/" + PostRank::URI.escape(doi)
      response = Maremma.get(url, options.merge(host: true))

      metadata = response.body.fetch("data", {}).fetch("message", {})
      return { error: 'Resource not found.', status: 404 } if metadata.blank?

      # don't use these metadata
      metadata = metadata.except("URL", "update-policy")

      date_parts = metadata.fetch("issued", {}).fetch("date-parts", []).first

      # Don't set issued if date-parts are missing.
      if !date_parts.nil?
        year, month, day = date_parts[0], date_parts[1], date_parts[2]

        # set date published if date issued is in the future
        if year.nil? || Date.new(*date_parts) > Time.zone.now.to_date
          metadata["issued"] = metadata.fetch("indexed", {}).fetch("date-time", nil)
          metadata["published"] = get_date_from_parts(year, month, day)
        else
          metadata["issued"] = get_date_from_parts(year, month, day)
          metadata["published"] = metadata["issued"]
        end
      # handle missing date issued, e.g. for components
      else
        metadata["issued"] = metadata.fetch("created", {}).fetch("date-time", nil)
        metadata["published"] = metadata["issued"]
      end

      metadata["deposited"] = metadata.fetch("deposited", {}).fetch("date-time", nil)
      metadata["updated"] = metadata.fetch("indexed", {}).fetch("date-time", nil)

      metadata["title"] = case metadata["title"].length
            when 0 then nil
            when 1 then metadata["title"][0]
            else metadata["title"][0].presence || metadata["title"][1]
            end

      if metadata["title"].blank? && !TYPES_WITH_TITLE.include?(metadata["type"])
        metadata["title"] = metadata["container-title"][0].presence || "(:unas)"
      end

      metadata["registration_agency_id"] = "crossref"
      metadata["publisher_id"] = metadata.fetch("member", "")[30..-1]
      metadata["container-title"] = metadata.fetch("container-title", [])[0]

      metadata["resource_type_id"] = "Text"
      metadata["resource_type"] = metadata["type"] if metadata["type"]
      metadata["author"] = metadata["author"].map { |author| author.except("affiliation") } if metadata["author"]

      metadata
    end

    def get_datacite_metadata(doi, options = {})
      return {} if doi.blank?

      params = { q: "doi:" + doi,
                 rows: 1,
                 fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,resourceType,datacentre,datacentre_symbol,prefix,relatedIdentifier,xml,minted,updated",
                 wt: "json" }
      url = "https://search.datacite.org/api?" + URI.encode_www_form(params)

      response = Maremma.get(url, options)

      metadata = response.body.fetch("data", {}).fetch("response", {}).fetch("docs", []).first
      return { error: 'Resource not found.', status: 404 } if metadata.blank?

      doi = metadata.fetch("doi", nil)
      doi = doi.upcase if doi.present?
      title = metadata.fetch("title", []).first
      title = title.chomp(".") if title.present?

      xml = Base64.decode64(metadata.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      doc = Nokogiri::XML(xml)
      issued = doc.at_xpath('//xmlns:date[@dateType="Issued"]')
      issued = issued.text if issued.present?

      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)

      { "author" => get_hashed_authors(authors),
        "title" => title,
        "container-title" => metadata.fetch("publisher", nil),
        "published" => metadata.fetch("publicationYear", nil),
        "deposited" => metadata.fetch("minted", nil),
        "issued" => issued,
        "updated" => metadata.fetch("updated", nil),
        "DOI" => doi,
        "resource_type_id" => metadata.fetch("resourceTypeGeneral", nil),
        "resource_type" => metadata.fetch("resourceType", nil),
        "publisher_id" => metadata.fetch("datacentre_symbol", nil),
        "registration_agency_id" => "datacite" }
    end

    def get_orcid_metadata(orcid, options = {})
      return {} if orcid.blank?

      url = "https://pub.orcid.org/v2.0/#{orcid}/person"
      response = Maremma.get(url, options.merge(accept: "json"))

      name = response.body.fetch("data", {}).fetch("name", nil)
      return { "errors" => 'Resource not found.' } unless name.present?

      author = { "family" => name.fetch("family-name", {}).fetch("value", nil),
                 "given" => name.fetch("given-names", {}).fetch("value", nil) }

      { "author" => [author],
        "title" => "ORCID record for #{[author.fetch('given', nil), author.fetch('family', nil)].compact.join(' ')}",
        "container-title" => "ORCID Registry",
        "issued" => Time.zone.now.year.to_s,
        "URL" => orcid_as_url(orcid),
        "type" => 'entry' }
    end

    def get_github_metadata(url, options = {})
      return {} if url.blank?

      github_hash = github_from_url(url)
      repo_url = "https://api.github.com/repos/#{github_hash[:owner]}/#{github_hash[:repo]}"
      response = Maremma.get(repo_url, options.merge(bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

      return { error: 'Resource not found.', status: 404 } if response.body.fetch("errors", nil).present?

      author = get_github_owner(github_hash[:owner])

      language = response.body.fetch("data", {}).fetch('language', nil)
      type = language.present? && language != "HTML" ? 'computer_program' : 'webpage'

      { "author" => [get_one_author(author)],
        "title" => response.body.fetch("data", {}).fetch('description', nil).presence || github_hash[:repo],
        "container-title" => "Github",
        "issued" => response.body.fetch("data", {}).fetch('created_at', nil).presence || "0000",
        "URL" => url,
        "type" => type }
    end

    def get_github_owner_metadata(url, options = {})
      return {} if url.blank?

      github_hash = github_from_url(url)
      owner_url = "https://api.github.com/users/#{github_hash[:owner]}"
      response = Maremma.get(owner_url, options.merge(bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

      return { error: 'Resource not found.', status: 404 } if response.body.fetch("data", {}).fetch("message", nil) == "Not Found"

      author = response.body.fetch("data", {}).fetch('name', nil).presence || github_hash[:owner]
      title = "Github profile for #{author}"

      { "author" => [get_one_author(author)],
        "title" => title,
        "container-title" => "Github",
        "issued" => response.body.fetch("data", {}).fetch('created_at', nil).presence || "0000",
        "URL" => url,
        "type" => 'entry' }
    end

    def get_github_release_metadata(url, options = {})
      return {} if url.blank?

      github_hash = github_from_url(url)
      release_url = "https://api.github.com/repos/#{github_hash[:owner]}/#{github_hash[:repo]}/releases/tags/#{github_hash[:release]}"
      response = Maremma.get(release_url, options.merge(bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

      return { error: 'Resource not found.', status: 404 } if response.body.fetch("data", {})["message"] == "Not Found"

      author = get_github_owner(github_hash[:owner])

      { "author" => [get_one_author(author)],
        "title" => response.body.fetch("data", {}).fetch('name', nil),
        "container-title" => "Github",
        "issued" => response.body.fetch("data", {}).fetch('created_at', nil).presence || "0000",
        "URL" => url,
        "type" => 'computer_program' }
    end

    def get_github_owner(owner)
      url = "https://api.github.com/users/#{owner}"
      response = Maremma.get(url, bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN'])

      return nil if response.body.fetch("data", {}).fetch("message", nil) == "Not Found"

      response.body.fetch("data", {}).fetch('name', nil).presence || owner
    end

    def get_pubmed_metadata(pmid, options = {})
      return {} if pmid.blank?

      url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ext_id:#{pmid}&format=json"
      response = Maremma.get(url, options)

      metadata = response.body.fetch("data", {}).fetch("resultList", {}).fetch("result", []).first
      return { error: 'Resource not found.', status: 404 } if metadata.blank?

      metadata["issued"] = metadata.fetch("pubYear", nil)

      author_string = metadata.fetch("authorString", "").chomp(".")
      metadata["author"] = get_authors(author_string.split(", "))

      metadata["title"] = metadata.fetch("title", "").chomp(".")
      metadata["container-title"] = metadata.fetch("journalTitle", nil)
      metadata["volume"] = metadata.fetch("journalVolume", nil)
      metadata["page"] = metadata.fetch("pageInfo", nil)
      metadata["type"] = "article-journal"

      metadata
    end

    def metadata_for_datacite(metadata)
      creators = metadata["author"].map do |a|
        { given_name: a["given"],
          family_name: a["family"],
          orcid: a["orcid"] }.compact
      end

      { "doi" => metadata["DOI"],
        "url" => metadata["URL"],
        "creators" => creators,
        "title" => metadata["title"],
        "publisher" => metadata["container-title"],
        "publication_year" => metadata["published"].present? ? metadata["published"][0..3] : nil,
        "resource_type" => { value: metadata["resource_type"],
                             resource_type_general: metadata["resource_type_id"] },
        "date_issued" => metadata["issued"],
        "date_updated" => metadata["updated"] }.compact
    end

    def datacite_xml(metadata)
      Cirneco::Work.new(metadata)
    end
  end
end
