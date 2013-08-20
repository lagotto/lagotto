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

require 'net/http'
require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'

module SourceHelper
  # default timeout is 60 sec
  DEFAULT_TIMEOUT = 60

  def get_json(url, options={})
    body = get_http_body(url, options)
    (body.nil? or body.length < 2) ? nil : ActiveSupport::JSON.decode(body)
  end

  def get_xml(url, options={}, &block)
    remove_doctype = options.delete(:remove_doctype)
    body = get_http_body(url, options)

    unless body.blank?
      # We got something. Conditionally remove the DOCTYPE to prevent
      # attempts to load the .dtd - we don't need it, and don't want
      # errors if it's missing.
      body.sub!(%r{\<\!DOCTYPE\s.*\>$}, '') if remove_doctype
      yield(parse_xml(body))
    else
      yield
    end
  end

  def parse_xml(text)
    Nokogiri::XML(text)
  end

  def save_alm_data(data_rev, data, id)

    service_url = APP_CONFIG['couchdb_url']

    # set the revision information
    unless data_rev.nil?
      data[:_id] = "#{id}"
      data[:_rev] = data_rev
    end

    response = put_alm_data("#{service_url}#{id}", ActiveSupport::JSON.encode(data))

    return nil if response.nil?

    result = ActiveSupport::JSON.decode(response.body)
    result["rev"]
  end

  def get_alm_data(id)
    service_url = APP_CONFIG['couchdb_url']
    data = get_json("#{service_url}#{id}")
  end

  def save_to_file(url, filename = "tmpdata", options={})
    body = get_http_body(url, options)
    if body.blank?
      return nil
    else
      begin
        File.open("#{Rails.root}/data/#{filename}", 'w') { |file| file.write(body) }
        return filename
      rescue => exception
        ErrorMessage.create(:exception => exception, :class_name => exception.class.to_s,
                            :message => exception.message,
                            :status => 500,
                            :source_id => options[:source_id])
        return nil
      end
    end
  end

  def get_original_url(doi, limit = 10)
    conn = Faraday.new(:url => "http://dx.doi.org") do |faraday|
      faraday.use FaradayMiddleware::FollowRedirects, :limit => limit
      faraday.use :cookie_jar
      faraday.adapter Faraday.default_adapter
    end

    response = conn.head Addressable::URI.encode(doi)
    # Some publishers respond with a 403 error for the original URL
    if response.status == 200 or (401..403) === response.status
      response.env[:url].to_s
    elsif response.status == 404 # not found
      return ""
    else
      ErrorMessage.create(:exception => "", :class_name => response.class.to_s,
                          :message => "Could not get the full URL for #{doi}, received #{response.env[:url].to_s} as last URL.",
                          :status => response.status)
      return ""
    end
  end

  #protected
  def get_http_body(uri, options={})
    # removing retrieval_status object from the hash
    options = options.except(:retrieval_status)

    optsMsg = options.empty? ? "" : " with #{options.inspect}"

    url = Addressable::URI.parse(uri)

    response = nil

    if options.empty?
      http = Net::HTTP.new(url.host, url.port)
      begin
        Timeout.timeout(DEFAULT_TIMEOUT) do
          response = http.request(Net::HTTP::Get.new(url.request_uri))
        end
      rescue Timeout::Error
        response = Net::HTTPRequestTimeOut.new(1.1, 408, "Request Timeout")
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

      http = Net::HTTP.new(url.host, url.port)
      begin
        Timeout.timeout(timeout) do
          http.use_ssl = true if (url.scheme == 'https')
          if options[:postdata]
            response = http.post(url.path, options[:postdata], headers)
          else
            response = http.request(request)
          end
        end
      rescue Timeout::Error
        response = Net::HTTPRequestTimeOut.new(1.1, 408, "Request Timeout")
      end
    end

    Rails.logger.info "Requested #{uri}#{optsMsg}, got: #{response.code}, #{response.message}"

    Rails.logger.debug "Response headers:"
    response.each_header do |key, value|
      Rails.logger.debug "[#{key}] = '#{value}']"
    end

    # Store error_message and return empty body unless response is 2xx or 404, don't raise an error
    if response.kind_of?(Net::HTTPSuccess) or response.kind_of?(Net::HTTPNotFound)
      return response.body
    else
      ErrorMessage.create(:exception => "", :class_name => response.class.to_s,
                          :message => "#{response.message} while requesting #{uri}",
                          :status => response.code,
                          :source_id => options[:source_id])
      return ""
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

    url = Addressable::URI.parse(url)

    req = Net::HTTP::Put.new(url.path)
    req["content-type"] = "application/json"
    req.body = json

    request(req)
  end

  def delete_alm_data(url)

    url = Addressable::URI.parse(url)

    req = Net::HTTP::Delete.new("#{url.path}?#{url.query}")
    request(req)
  end

  def get_alm_database
    # get information about CouchDB database
    service_url = APP_CONFIG['couchdb_url']
    get_json(service_url)
  end

  def put_alm_database
    # create CouchDB test database
    if Rails.env.test?
      service_url = APP_CONFIG['couchdb_url']
      url = Addressable::URI.parse(service_url)

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
      url = Addressable::URI.parse(service_url)

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
    #url = Addressable::URI.parse(service_url)
    url = URI.parse(service_url)

    response = Net::HTTP.start(url.host, url.port) { |http|http.request(req) }
    if response.kind_of?(Net::HTTPSuccess) or response.kind_of?(Net::HTTPNotFound)
      response
    else
      ErrorMessage.create(:exception => "", :class_name => response.class.to_s,
                          :message => "#{response.message} while requesting \"#{url.scheme}://#{url.host}:#{url.port}#{req.path}\"",
                          :status => response.code)
      nil
    end
  end
end
