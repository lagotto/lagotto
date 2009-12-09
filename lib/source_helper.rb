require 'rubygems'
require 'system_timer'

module SourceHelper
  include Log
  
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
        sUrl = url.path

        if url.query
          sUrl= sUrl + "?" + url.query
        end

        log_info("url: #{sUrl}")
        log_info("timeout: #{options[:timeout]}")

        request = Net::HTTP::Get.new(sUrl)
        
        if options[:username] 
          request.basic_auth(options[:username], options[:password]) 
        end
        
        request.each_header do |key, value|
          log_info("[#{key}] = '#{value}'")
        end
        
        log_info("Making Request")

        #There is an issue with Ruby and Socket Timeouts
        #Hostname resolvs timing out will not be caught
        #by the following system time.  At least that is the behavior 
        #I saw.  Note the following:
        #http://www.mikeperham.com/2009/03/15/socket-timeouts-in-ruby/
        #http://groups.google.com/group/comp.lang.ruby/browse_thread/thread/c14cfd560cf253d2/bbb0f2e8309f3467?lnk=gst&q=dns+timeout#bbb0f2e8309f3467
        #http://ph7spot.com/musings/system-timer

        SystemTimer.timeout_after(options[:timeout]) do
          response = Net::HTTP.new(url.host, url.port).start do |http| 
            http.request(request)
          end
        end
        log_info("Request Complete")
      end
      case response
      when Net::HTTPForbidden # CrossRef returns this for "DOI not found"
        ""
      when Net::HTTPSuccess, Net::HTTPRedirection
        log_info("Requested #{uri}#{optsMsg}, got: #{response.body}")

        response.each_header do |key, value|
          log_info("[#{key}] = '#{value}']")
        end
        
        response.body # OK
      else
        response.error!
      end
    rescue
      log_error("Error (#{$!.class.name}) while requesting #{uri}#{optsMsg}")
      raise
    rescue Timeout::Error
      log_error("Error (#{$!.class.name}) while requesting #{uri}#{optsMsg}")
      raise
    end
  end

end
