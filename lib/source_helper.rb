# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'system_timer'

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
      options = options.except(:retrieval)

      url = URI.parse(uri)
      
      if options.empty?
        response = Net::HTTP.get_response(url)
      else
        sUrl = url.path

        if url.query
          sUrl= sUrl + "?" + url.query
        end

        Rails.logger.debug "http request: #{sUrl} (timeout: #{options[:timeout]})"

        request = Net::HTTP::Get.new(sUrl, { "User-Agent" => APP_CONFIG['useragent'] + " - " + APP_CONFIG['hostname']  })
        
        if options[:username] 
          request.basic_auth(options[:username], options[:password]) 
        end
        
        Rails.logger.debug "Request headers:"
        request.each_header do |key, value|
          Rails.logger.debug "[#{key}] = '#{value}'"
        end
        
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
      end
      case response
      when Net::HTTPForbidden # CrossRef returns this for "DOI not found"
        ""
      when Net::HTTPSuccess, Net::HTTPRedirection
        Rails.logger.info "Requested #{uri}#{optsMsg}, got: #{response.body}"

        Rails.logger.debug "Response headers:"
        response.each_header do |key, value|
          Rails.logger.debug "[#{key}] = '#{value}']"
        end
        
        response.body # OK
      else
        response.error!
      end
    rescue Exception => e
      Rails.logger.error "Error (#{e.class.name}: #{e.message}) while requesting #{uri}#{optsMsg}"
      raise e
    end
  end

end
