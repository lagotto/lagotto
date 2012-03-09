
module SourceHelper
  # default timeout is 60 sec
  DEFAULT_TIMEOUT = 60

  def get_json(url, options={})
    body = get_http_body(url, options)
    (body.length > 0) ? ActiveSupport::JSON.decode(body) : []
  end

  def get_xml(url, options={}, &block)
    remove_doctype = options.delete(:remove_doctype)
    body = get_http_body(url, options)
    return [] if body.length == 0

    # We got something. Conditionally remove the DOCTYPE to prevent
    # attempts to load the .dtd - we don't need it, and don't want
    # errors if it's missing.
    body.sub!(%r{\<\!DOCTYPE\s.*\>$}, '') if remove_doctype
    yield(parse_xml(body))
  end

  def parse_xml(text)
    XML::Parser.string(text).parse
  end

  def save_alm_data(data_rev, data, id)

    service_url = APP_CONFIG['couchdb_url']

    # set the revision information
    unless data_rev.nil?
      data[:_id] = "#{id}"
      data[:_rev] = data_rev
    end

    begin
      response = put_alm_data("#{service_url}#{id}", ActiveSupport::JSON.encode(data))
    rescue => e
      puts "#{e}"
      if e.respond_to?('response')
        if e.response.kind_of?(Net::HTTPConflict)
          # something went wrong
          # get the most current revision value and use that to put the data one more time
          cur_data = get_json("#{service_url}#{id}")
          data[:_id] = cur_data["_id"]
          data[:_rev] = cur_data["_rev"]

          response = put_alm_data("#{service_url}#{id}", ActiveSupport::JSON.encode(data))
        else
          raise e
        end
      else
        raise e
      end
    end

    result = ActiveSupport::JSON.decode(response.body)

    result["rev"]
  end

  protected
  def get_http_body(uri, options={})
    optsMsg = " with #{options.inspect}" unless options.empty?
    begin
      # TODO where does retrieval get used?
      options = options.except(:retrieval)

      url = URI.parse(uri)

      response = nil

      if options.empty?
        Timeout.timeout(DEFAULT_TIMEOUT) do
          response = Net::HTTP.get_response(url)
        end
      else
        sUrl = url.path

        if url.query
          sUrl= sUrl + "?" + url.query
        end

        Rails.logger.debug "http request: #{sUrl} (timeout: #{options[:timeout]})"

        headers = { "User-Agent" => APP_CONFIG['useragent'] + " - " + APP_CONFIG['hostname'] }
        # TODO WHO USES THIS?
        if options[:extraheaders]
          extraHeaders = options[:extraheaders]
          extraHeaders.each do | key, value |
            headers[key] = value
          end
        end

        request = Net::HTTP::Get.new(sUrl, headers)

        if options[:username]
          request.basic_auth(options[:username], options[:password])
        end

        Rails.logger.debug "Request headers:"
        request.each_header do |key, value|
          Rails.logger.debug "[#{key}] = '#{value}'"
        end

        timeout = options[:timeout].nil? ? DEFAULT_TIMEOUT : options[:timeout]
        Timeout.timeout(timeout) do
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true if (url.scheme == 'https')
          if options[:postdata]
            response = http.post(url.path, options[:postdata], headers)
          else
            response = http.request(request)
          end
        end
      end

      # TODO don't output everything!  makes the log file unreadable.  too much info
      Rails.logger.info "Requested #{uri}#{optsMsg}, got: #{response.body}"

      Rails.logger.debug "Response headers:"
      response.each_header do |key, value|
        Rails.logger.debug "[#{key}] = '#{value}']"
      end

      case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          response.body # OK
        else
          response.error!
      end

    rescue Exception => e
      puts "Error #{e}"
      Rails.logger.error "Error (#{e.class.name}: #{e.message}) while requesting #{uri}#{optsMsg}"
      raise e
    end
  end

  def put_alm_data(url, json)

    url = URI.parse(url)

    req = Net::HTTP::Put.new(url.path)
    req["content-type"] = "application/json"
    req.body = json

    res = Net::HTTP.start(url.host, url.port) { | http | http.request(req) }

    unless res.kind_of?(Net::HTTPSuccess)
      res.error!
    end

    res
  end

end