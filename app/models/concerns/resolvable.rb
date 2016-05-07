module Resolvable
  extend ActiveSupport::Concern

  included do
    require "addressable/uri"

    def get_canonical_url(url, options={})
      options[:content_type] = "html"
      options[:headers] ||= {}
      options[:headers] = set_request_headers(url, options)

      conn = faraday_conn(options)
      conn.options[:timeout] = options[:timeout] || 120

      response = conn.get url, {}, options[:headers]

      if options[:no_redirect]
        url = response.headers[:location].to_s
      else
        url = response.env[:url].to_s
      end

      return nil unless url.present?

      # remove jsessionid used by J2EE servers
      url = url.gsub(/(.*);jsessionid=.*/, '\1')

      # normalize URL, e.g. remove percent encoding and make host lowercase
      url = PostRank::URI.clean(url)

      # remove parameter used by IEEE
      url = url.sub("reload=true&", "")

      # remove parameter used by ScienceDirect
      url = url.sub("?via=ihub", "")

      url
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options.merge(doi_lookup: true))
    end

    # url returned by handle server, redirects are not followed
    def get_handle_url(url, options={})
      get_canonical_url(url, options.merge(no_redirect: true))
    end

    def get_normalized_url(url)
      url = PostRank::URI.clean(url)
      if PostRank::URI.valid?(url)
        url
      end
    rescue Addressable::URI::InvalidURIError => e
      { error: e.message }
    end

    def get_pid(options)
      id_hash = options.compact

      if id_hash.present?
        id_as_pid(id_hash)
      else
        { error: "must provide at least one persistent identifier" }
      end
    end

    def id_as_pid(id_hash)
      key, value = id_hash.first
      case key
      when :doi then doi_as_url(value)
      when :pmid then pmid_as_url(value)
      when :pmcid then pmcid_as_url(value)
      when :arxiv then arxiv_as_url(value)
      when :ark then ark_as_url(value)
      when :dataone then dataone_as_url(value)
      when :canonical_url then value
      else nil
      end
    end

    # normalize pid, e.g. http://dx.doi.org/10.5555/123 to http://doi.org/10.5555/123
    def normalize_pid(pid)
      id_hash = get_id_hash(pid)
      id_as_pid(id_hash)
    end

    # documentation at http://www.ncbi.nlm.nih.gov/pmc/tools/id-converter-api/
    def get_persistent_identifiers(id, idtype, options = {})
      return {} if id.blank?
      options[:timeout] ||= 120

      params = { 'tool' => "Lagotto - http://#{ENV['SERVERNAME']}",
                 'email' => ENV['ADMIN_EMAIL'],
                 'ids' => id,
                 'idtype' => idtype,
                 'format' => 'json' }
      url = "https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?" + params.to_query
      response = get_result(url, options)

      return { error: 'Resource not found.', status: 404 } if response.fetch("records", {}).first.fetch("status", nil) == "error"

      response.fetch("records", {}).first
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

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
      response = get_result(url, options.merge(host: true))

      metadata = response.fetch("message", {})
      return { error: 'Resource not found.', status: 404 } if metadata.blank?

      # don't use these metadata
      metadata = metadata.except("URL", "indexed", "created", "deposited", "update-policy")

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
        end
      end

      metadata["title"] = case metadata["title"].length
            when 0 then nil
            when 1 then metadata["title"][0]
            else metadata["title"][0].presence || metadata["title"][1]
            end

      if metadata["title"].blank? && !TYPES_WITH_TITLE.include?(metadata["type"])
        metadata["title"] = metadata["container-title"][0].presence || "(:unas)"
      end

      metadata["publisher_id"] = metadata.fetch("member", "")[30..-1]
      metadata["container-title"] = metadata.fetch("container-title", [])[0]
      metadata["type"] = CROSSREF_TYPE_TRANSLATIONS[metadata["type"]] if metadata["type"]
      metadata["author"] = metadata["author"].map { |author| author.except("affiliation") } if metadata["author"]

      metadata
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def get_datacite_metadata(doi, options = {})
      return {} if doi.blank?

      params = { q: "doi:" + doi,
                 rows: 1,
                 fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre,datacentre_symbol,prefix,relatedIdentifier,xml,minted,updated",
                 wt: "json" }
      url = "http://search.datacite.org/api?" + URI.encode_www_form(params)

      response = get_result(url, options)

      metadata = response.fetch("response", {}).fetch("docs", []).first
      return { error: 'Resource not found.', status: 404 } if metadata.blank?

      type = metadata.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS.fetch(type, nil) if type

      doi = metadata.fetch("doi", nil)
      doi = doi.upcase if doi.present?
      title = metadata.fetch("title", []).first
      title = title.chomp(".") if title.present?

      xml = Base64.decode64(metadata.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)

      { "author" => get_hashed_authors(authors),
        "title" => title,
        "container-title" => metadata.fetch("publisher", nil),
        "published" => metadata.fetch("publicationYear", nil),
        "issued" => metadata.fetch("minted", nil),
        "DOI" => doi,
        "type" => type,
        "publisher_id" => metadata.fetch("datacentre_symbol", nil) }
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def get_orcid_metadata(orcid, options = {})
      return {} if orcid.blank?

      url = "http://pub.orcid.org/v1.2/#{orcid}/orcid-bio"
      response = get_result(url, options)

      metadata = response.fetch("orcid-profile", nil)
      return { error: 'Resource not found.', status: 404 } unless metadata.present?

      metadata.extend Hashie::Extensions::DeepFetch
      personal_details = metadata.deep_fetch("orcid-bio", "personal-details") { {} }
      personal_details.extend Hashie::Extensions::DeepFetch
      author = { "family" => personal_details.deep_fetch("family-name", "value") { nil },
                 "given" => personal_details.deep_fetch("given-names", "value") { nil } }
      url = metadata.deep_fetch("orcid-identifier", "uri") { nil }

      { "author" => [author],
        "title" => "ORCID record for #{author.fetch('given', '')} #{author.fetch('family', '')}",
        "container-title" => "ORCID Registry",
        "issued" => Time.zone.now.year.to_s,
        "URL" => url,
        "type" => 'entry' }
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def get_github_metadata(url, options = {})
      return {} if url.blank?

      github_hash = github_from_url(url)
      repo_url = "https://api.github.com/repos/#{github_hash[:owner]}/#{github_hash[:repo]}"
      response = get_result(repo_url, options.merge(bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

      return { error: 'Resource not found.', status: 404 } if response[:error]

      author = get_github_owner(github_hash[:owner])

      language = response.fetch('language', nil)
      type = language.present? && language != "HTML" ? 'computer_program' : 'webpage'

      { "author" => [get_one_author(author)],
        "title" => response.fetch('description', nil).presence || github_hash[:repo],
        "container-title" => "Github",
        "issued" => response.fetch('created_at', nil).presence || "0000",
        "URL" => url,
        "type" => type }
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def get_github_owner_metadata(url, options = {})
      return {} if url.blank?

      github_hash = github_from_url(url)
      owner_url = "https://api.github.com/users/#{github_hash[:owner]}"
      response = get_result(owner_url, options.merge(bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

      return { error: 'Resource not found.', status: 404 } if response["message"] == "Not Found"

      author = response.fetch('name', nil).presence || github_hash[:owner]
      title = "Github profile for #{author}"

      { "author" => [get_one_author(author)],
        "title" => title,
        "container-title" => "Github",
        "issued" => response.fetch('created_at', nil).presence || "0000",
        "URL" => url,
        "type" => 'entry' }
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def get_github_release_metadata(url, options = {})
      return {} if url.blank?

      github_hash = github_from_url(url)
      release_url = "https://api.github.com/repos/#{github_hash[:owner]}/#{github_hash[:repo]}/releases/tags/#{github_hash[:release]}"
      response = get_result(release_url, options.merge(bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

      return { error: 'Resource not found.', status: 404 } if response["message"] == "Not Found"

      author = get_github_owner(github_hash[:owner])

      { "author" => [get_one_author(author)],
        "title" => response.fetch('name', nil),
        "container-title" => "Github",
        "issued" => response.fetch('created_at', nil).presence || "0000",
        "URL" => url,
        "type" => 'computer_program' }
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def get_github_owner(owner)
      url = "https://api.github.com/users/#{owner}"
      response = get_result(url, bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN'])

      return nil if response["message"] == "Not Found"

      response.fetch('name', nil).presence || owner
    rescue *NETWORKABLE_EXCEPTIONS
      nil
    end

    def get_pubmed_metadata(pmid, options = {})
      return {} if pmid.blank?

      url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ext_id:#{pmid}&format=json"
      response = get_result(url, options)

      metadata = response.fetch("resultList", {}).fetch("result", []).first
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
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    # lookup registration agency for a given doi
    # first lookup cached prefixes
    # return hash with keys :name, :title, or :error
    def get_doi_ra(doi, options = {})
      return {} if doi.blank?

      options[:timeout] ||= 120
      doi = CGI.unescape(clean_doi(doi))
      prefix_string = Array(/^(10\.\d{4,5})\/.+/.match(doi)).last
      return {} if prefix_string.blank?

      prefix = cached_prefix(prefix_string)
      return { id: prefix.registration_agency.id,
               name: prefix.registration_agency.name,
               title: prefix.registration_agency.title } if prefix.present?

      url = "http://doi.crossref.org/doiRA/#{doi}"
      response = get_result(url, options.merge(host: true))

      ra = response.first.fetch("RA", nil)
      if ra.present?
        registration_agency = cached_registration_agency(ra.delete(' ').downcase)
        registration_agency.prefixes.where(name: prefix_string).first_or_create
        { id: registration_agency.id,
          name: registration_agency.name,
          title: registration_agency.title }
      else
        error = response.first.fetch("status", "An error occured")
        { error: error, status: 400 }
      end
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    # remove non-printing whitespace
    def clean_doi(doi)
      doi.gsub(/\u200B/, '')
    end

    def get_id_hash(id)
      return {} if id.nil?

      id = id.gsub("%2F", "/")
      id = id.gsub("%3A", ":")

      # workaround, as nginx and the rails router swallow double backslashes
      id = id.gsub(/(http|https):\/+(\w+)/, '\1://\2')

      case
      when id.starts_with?("doi.org/")           then { doi: CGI.unescape(id[8..-1]).upcase }
      when id.starts_with?("www.ncbi.nlm.nih.gov/pubmed/")                  then { pmid: id[28..-1] }
      when id.starts_with?("www.ncbi.nlm.nih.gov/pmc/articles/PMC")         then { pmcid: id[37..-1] }
      when id.starts_with?("arxiv.org/abs/")     then { arxiv: id[14..-1] }
      when id.starts_with?("n2t.net/ark:")       then { ark: id[8..-1] }
      when id.starts_with?("github.com/")        then { canonical_url: "https://#{PostRank::URI.clean(id)}" }

      when id.starts_with?("http://doi.org/")    then { doi: CGI.unescape(id[15..-1]).upcase }
      when id.starts_with?("http://dx.doi.org/") then { doi: CGI.unescape(id[18..-1]).upcase }
      when id.starts_with?("http://www.ncbi.nlm.nih.gov/pubmed/")           then { pmid: id[35..-1] }
      when id.starts_with?("http://www.ncbi.nlm.nih.gov/pmc/articles/PMC")  then { pmcid: id[44..-1] }
      when id.starts_with?("http://arxiv.org/abs/")                         then { arxiv: id[21..-1] }
      when id.starts_with?("http://n2t.net/ark:")                           then { ark: id[15..-1] }
      when id.starts_with?("http:")              then { canonical_url: PostRank::URI.clean(id) }
      when id.starts_with?("https:")             then { canonical_url: PostRank::URI.clean(id) }

      when id.starts_with?("doi:")               then { doi: CGI.unescape(id[4..-1]).upcase }
      when id.starts_with?("pmid:")              then { pmid: id[5..-1] }
      when id.starts_with?("pmcid:PMC")          then { pmcid: id[9..-1] }
      when id.starts_with?("pmcid:")             then { pmcid: id[6..-1] }
      when id.starts_with?("arxiv:")             then { arxiv: id[6..-1] }
      when id.starts_with?("wos:")               then { wos: id[4..-1] }
      when id.starts_with?("scp:")               then { scp: id[4..-1] }
      when id.starts_with?("ark:")               then { ark: id }

      when id.starts_with?("doi/")               then { doi: CGI.unescape(id[4..-1]).upcase }
      when id.starts_with?("info:doi/")          then { doi: CGI.unescape(id[9..-1]).upcase }
      when id.starts_with?("10.")                then { doi: CGI.unescape(id).upcase }
      when id.starts_with?("pmid/")              then { pmid: id[5..-1] }
      when id.starts_with?("pmcid/PMC")          then { pmcid: id[9..-1] }
      when id.starts_with?("pmcid/")             then { pmcid: id[6..-1] }
      when id.starts_with?("PMC")                then { pmcid: id[3..-1] }
      when id.starts_with?("doi_10.")            then { doi: id[4..-1].gsub("_", "/").upcase }
      else {}
      end
    end

    def get_clean_id(id)
      if id.starts_with? "10."
        Addressable::URI.unencode(id)
      elsif id.starts_with? "PMC"
        id[3..-1]
      else
        id
      end
    end
  end
end
