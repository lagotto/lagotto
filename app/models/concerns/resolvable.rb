module Resolvable
  extend ActiveSupport::Concern

  included do
    require "maremma"

    def get_canonical_url(url, options={})
      response = Maremma.get(url, options)
      return response.body["errors"].first if response.body["errors"].present?

      if options[:limit] == 0
        canonical_url = response.headers[:location].to_s
      else
        canonical_url = response.url
      end

      # remove jsessionid used by J2EE servers
      canonical_url = canonical_url.gsub(/(.*);jsessionid=.*/, '\1')

      # normalize URL, e.g. remove percent encoding and make host lowercase
      canonical_url = PostRank::URI.clean(canonical_url)

      # remove parameter used by IEEE
      canonical_url = canonical_url.sub("reload=true&", "")

      # remove parameter used by ScienceDirect
      canonical_url = canonical_url.sub("?via=ihub", "")

      { url: canonical_url }
    end

    # url returned by handle server, redirects are not followed
    def get_handle_url(url, options={})
      get_canonical_url(url, options.merge(limit: 0))
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
      response = Maremma.get(url, options)

      return { error: 'Resource not found.', status: 404 } if response.body.fetch("data", {}).fetch("records", {}).first.fetch("status", nil) == "error"

      response.body.fetch("data", {}).fetch("records", {}).first
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

      url = "http://doi.crossref.org/doiRA/#{doi}"
      response = Maremma.get(url, options.merge(host: true))

      ra = response.body.fetch("data", {}).first.fetch("RA", nil)
      if ra.present?
        ra = ra.delete(' ').downcase
        { id: ra,
          title: ra.titleize }
      else
        { errors: response.body.fetch("data", {}) }
      end
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

      # Try to match a DOI with HTTP or HTTPS, using any resolver.
      doi_match = /^https?:\/\/(dx\.)?doi.org\/(.*)$/.match(id)

      case
      when id.starts_with?("doi.org/")           then { doi: CGI.unescape(id[8..-1]).upcase }
      when id.starts_with?("www.ncbi.nlm.nih.gov/pubmed/")                  then { pmid: id[28..-1] }
      when id.starts_with?("www.ncbi.nlm.nih.gov/pmc/articles/PMC")         then { pmcid: id[37..-1] }
      when id.starts_with?("arxiv.org/abs/")     then { arxiv: id[14..-1] }
      when id.starts_with?("n2t.net/ark:")       then { ark: id[8..-1] }
      when id.starts_with?("github.com/")        then { canonical_url: PostRank::URI.clean(id) }

      when doi_match then { doi: CGI.unescape(doi_match[2]).upcase }
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
