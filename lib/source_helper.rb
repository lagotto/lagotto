# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
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

module SourceHelper
  # default timeout is 60 sec
  DEFAULT_TIMEOUT = 60

  def get_json(url, options={})
    body = get_http_body(url, options)
    body.blank? ? [] : ActiveSupport::JSON.decode(body)
  end

  def get_xml(url, options={}, &block)
    remove_doctype = options.delete(:remove_doctype)
    body = get_http_body(url, options)
    return [] if body.blank?

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
      ErrorMessage.create(:exception => e, :message => "Failed to put #{service_url}#{id}. Going to try to get the document to get the current _rev, #{e.message}")   
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

  def get_alm_data(id)
    service_url = APP_CONFIG['couchdb_url']
    data = get_json("#{service_url}#{id}")
  end

  def get_original_url(uri_str, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    response = Net::HTTP.get_response(URI(uri_str))

    case response
      when Net::HTTPSuccess then
        uri_str
      when Net::HTTPRedirection then
        location = response['location']

        # sometimes we can get a location that doesn't have the host information
        uri = URI(location)
        if uri.host.nil?
          orig_uri = URI(uri_str)
          location = "http://" + orig_uri.host + location
        end

        get_original_url(location, limit - 1)
      else
        Rails.logger.info "Couldn't not follow the url all the way #{response.value}"
    end
  end

  #protected
  def get_http_body(uri, options={})
    # removing retrieval_status object from the hash
    options = options.except(:retrieval_status)

    optsMsg = " with #{options.inspect}" unless options.empty?

    begin
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

      Rails.logger.info "Requested #{uri}#{optsMsg}, got: #{response.code}, #{response.message}"

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
      ErrorMessage.create(:exception => e, :message => "Error #{e.message} while requesting #{uri}#{optsMsg}", :response => response.inspect)
      raise e
    end
  end
  
  def remove_alm_data(data_rev, id)
    
    service_url = APP_CONFIG['couchdb_url']
    params = {'rev' => data_rev }

    response = delete_alm_data("#{service_url}#{id}?#{params.to_query}")
    result = ActiveSupport::JSON.decode(response.body)

    result["rev"]
  end

  def put_alm_data(url, json)

    url = URI.parse(url)

    req = Net::HTTP::Put.new(url.path)
    req["content-type"] = "application/json"
    req.body = json
    
    request(req)
  end
  
  def delete_alm_data(url)

    url = URI.parse(url)

    req = Net::HTTP::Delete.new("#{url.path}?#{url.query}")
    request(req)
  end
  
  def put_alm_database
    # create CouchDB test database
    if Rails.env.test?
      service_url = APP_CONFIG['couchdb_url']
      url = URI.parse(service_url)
    
      req = Net::HTTP::Put.new(url.path)
      unless (url.user.nil? or url.password.nil?)
        req.basic_auth url.user, url.password
      end
      request(req)
    else
      nil
    end
  end
  
  def delete_alm_database
    # delete CouchDB test database
    if Rails.env.test?
      service_url = APP_CONFIG['couchdb_url']
      url = URI.parse(service_url)
    
      req = Net::HTTP::Delete.new(url.path)
      unless (url.user.nil? or url.password.nil?)
        req.basic_auth url.user, url.password
      end
      request(req)
    else
      nil
    end
  end
  
  def request(req)
    service_url = APP_CONFIG['couchdb_url']
    url = URI.parse(service_url)
    
    res = Net::HTTP.start(url.host, url.port) { |http|http.request(req) }
    unless res.kind_of?(Net::HTTPSuccess)
      handle_error(req, res)
    end
    res
  end
  
  private

  def handle_error(req, res)
    e = RuntimeError.new("#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}")
    raise e
  end

end