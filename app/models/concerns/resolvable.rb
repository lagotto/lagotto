module Resolvable
  extend ActiveSupport::Concern

  included do

    def get_canonical_url(url, options = { timeout: 120 })
      conn = faraday_conn('html')

      conn.options[:timeout] = options[:timeout]
      response = conn.get url, {}, options[:headers]

      # Priority to find URL:
      # 1. <link rel=canonical />
      # 2. <meta property="og:url" />
      # 3. URL from header

      body = Nokogiri::HTML(response.body, nil, 'utf-8')
      body_url = body.at('link[rel="canonical"]')['href'] if body.at('link[rel="canonical"]')
      if !body_url && body.at('meta[property="og:url"]')
        body_url = body.at('meta[property="og:url"]')['content']
      end

      if body_url
        # normalize URL, e.g. remove percent encoding and make URL lowercase
        body_url = PostRank::URI.clean(body_url)

        # remove parameter used by IEEE
        body_url = body_url.sub("reload=true&", "")
      end

      url = response.env[:url].to_s
      if url
        # normalize URL, e.g. remove percent encoding and make URL lowercase
        url = PostRank::URI.clean(url)

        # remove jsessionid used by J2EE servers
        url = url.gsub(/(.*);jsessionid=.*/, '\1')

        # remove parameter used by IEEE
        url = url.sub("reload=true&", "")

        # remove parameter used by ScienceDirect
        url = url.sub("?via=ihub", "")
      end

      # get relative URL
      path = URI.split(url)[5]

      # we will raise an error if 1. or 2. doesn't match with 3. as this confuses Facebook
      if body_url.present? && ![url, path].include?(body_url)
        options[:doi_mismatch] = true
        response.env[:message] = "Canonical URL mismatch: #{body_url} for #{url}"
        fail Faraday::ResourceNotFound, response.env
      end

      # URL must be a string that contains at least one number
      # we don't want to store publisher landing or error pages
      fail Faraday::ResourceNotFound, response.env unless url =~ /\d/

      url
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options.merge(doi_lookup: true))
    end

    def get_normalized_url(url)
      PostRank::URI.clean(url)
    rescue Addressable::URI::InvalidURIError => e
      { error: e.message }
    end

    def get_url_from_doi(doi)
      Addressable::URI.encode("http://dx.doi.org/#{doi}")
    end

    def get_doi_from_id(id)
      if id.starts_with?("http://dx.doi.org/")
        uri = URI.parse(id)
        uri.path[1..-1]
      elsif id.starts_with?("doi:")
        id[4..-1]
      end
    end

    def get_persistent_identifiers(doi, options = { timeout: 120 })
      conn = faraday_conn('json')
      params = { 'ids' => doi,
                 'idtype' => "doi",
                 'format' => 'json' }
      url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?" + params.to_query

      conn.options[:timeout] = options[:timeout]
      response = conn.get url, {}, options[:headers]

      if is_json?(response.body)
        json = JSON.parse(response.body)
        json.extend Hashie::Extensions::DeepFetch
        json.deep_fetch('records', 0) { { error: 'not found' } }
      else
        { error: 'not found' }
      end
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def get_id_hash(id)
      return nil if id.nil?

      id = id.gsub("%2F", "/")
      id = id.gsub("%3A", ":")

      # workaround, as nginx and the rails router swallow double backslashes
      id = id.gsub(/(http|https|ftp):\//, '\1://')

      case
      when id.starts_with?("http://dx.doi.org/") then { doi: id[18..-1] }
      when id.starts_with?("doi/")               then { doi: CGI.unescape(id[4..-1]) }
      when id.starts_with?("info:doi/")          then { doi: CGI.unescape(id[9..-1]) }
      when id.starts_with?("10.")                then { doi: CGI.unescape(id) }
      when id.starts_with?("pmid/")              then { pmid: id[5..-1] }
      when id.starts_with?("info:pmid/")         then { pmid: id[10..-1] }
      when id.starts_with?("pmcid/PMC")          then { pmcid: id[9..-1] }
      when id.starts_with?("info:pmcid/PMC")     then { pmcid: id[14..-1] }
      when id.starts_with?("pmcid/")             then { pmcid: id[6..-1] }
      when id.starts_with?("PMC")                then { pmcid: id[3..-1] }
      when id.starts_with?("wos/")               then { wos: id[4..-1] }
      when id.starts_with?("info:wos/")          then { wos: id[9..-1] }
      when id.starts_with?("scp/")               then { scp: id[4..-1] }
      when id.starts_with?("info:scp/")          then { scp: id[9..-1] }
      when id.starts_with?("url/")               then { canonical_url: PostRank::URI.clean(id[4..-1]) }
      else { doi: id }
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
