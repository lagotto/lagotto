
module SourceHelper
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

protected
  def get_http_body(uri, options={})
    optsMsg = " with #{options.inspect}" unless options.empty?
    begin
      verbose = options[:verbose] || 0
      options = options.except(:verbose, :retrieval)
      url = URI.parse(uri)
      if options.empty?
        response = Net::HTTP.get_response(url)
      else
        request = Net::HTTP::Get.new(url.path)
        request.basic_auth(options[:username], options[:password]) \
          if options[:username]
        if verbose > 2
          puts "url: #{url}"
          request.each_header do |key, value|
            puts "[#{key}] = '#{value}']"
          end
        end
        response = Net::HTTP.new(url.host, url.port).start do |http| 
          http.request(request)
        end
      end

      case response
      when Net::HTTPForbidden # CrossRef returns this for "DOI not found"
        ""
      when Net::HTTPSuccess, Net::HTTPRedirection
        if verbose > 3
          puts "Requested #{uri}#{optsMsg}, got: #{response.body}" 
        end
        if verbose > 3
          response.each_header do |key, value|
            puts "[#{key}] = '#{value}']"
          end
        end
        response.body # OK
      else
        response.error!
      end
    rescue
      puts "Error (#{$!.class.name}) while requesting #{uri}#{optsMsg}"
      raise
    rescue Timeout::Error
      puts "Error (#{$!.class.name}) while requesting #{uri}#{optsMsg}"
      raise
    end
  end

end
