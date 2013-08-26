# encoding: UTF-8

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

require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'

module SourceHelper
  DEFAULT_TIMEOUT = 60
  SourceHelperExceptions = [Faraday::Error::ClientError, Delayed::WorkerTimeout, Errno::EPIPE, Errno::ECONNRESET].freeze

  def get_json(url, options = { timeout: DEFAULT_TIMEOUT })
    conn = conn_json
    conn.basic_auth(options[:username], options[:password]) if options[:username]
    conn.options[:timeout] = options[:timeout]
    response = conn.get url
    response.body
  rescue *SourceHelperExceptions => e
    rescue_faraday_error(url, e, options.merge(:json => true))
  end

  def get_xml(url, options = { timeout: DEFAULT_TIMEOUT })
    conn = conn_xml
    conn.basic_auth(options[:username], options[:password]) if options[:username]
    conn.options[:timeout] = options[:timeout]
    if options[:data]
      response = conn.post url do |request|
        request.body = options[:data]
      end
    else
      response = conn.get url
    end
    # We have issues with the Faraday XML parsing
    Nokogiri::XML(response.body)
  rescue *SourceHelperExceptions => e
    rescue_faraday_error(url, e, options.merge(:xml => true))
  end

  def post_xml(url, options = { data: nil, timeout: DEFAULT_TIMEOUT })
    get_xml(url, options)
  end

  def get_alm_data(id = "")
    get_json("#{couchdb_url}#{id}")
  end

  def get_alm_rev(id, options={})
    head_alm_data("#{couchdb_url}#{id}", options)
  end

  def head_alm_data(url, options = { timeout: DEFAULT_TIMEOUT })
    conn = conn_json
    conn.basic_auth(options[:username], options[:password]) if options[:username]
    conn.options[:timeout] = options[:timeout]
    response = conn.head url
    # CouchDB revision is in etag header. We need to remove extra double quotes
    rev = response.env[:response_headers][:etag][1..-2]
  rescue *SourceHelperExceptions => e
    rescue_faraday_error(url, e, options.merge(:head => true))
  end

  def save_alm_data(id, options = { :data => nil })
    data_rev = get_alm_rev(id)
    unless data_rev.nil?
      options[:data][:_id] = id
      options[:data][:_rev] = data_rev
    end

    put_alm_data("#{couchdb_url}#{id}", options)
  end

  def put_alm_data(url, options = { :data => nil })
    return nil unless options[:data] || Rails.env.test?
    conn = conn_json
    conn.options[:timeout] = DEFAULT_TIMEOUT
    response = conn.put url do |request|
      request.body = options[:data]
    end
    (response.body["ok"] ? response.body["rev"] : nil)
  rescue *SourceHelperExceptions => e
    rescue_faraday_error(url, e, options)
  end

  def remove_alm_data(id, data_rev)
    params = {'rev' => data_rev }
    delete_alm_data("#{couchdb_url}#{id}?#{params.to_query}")
  end

  def delete_alm_data(url, options={})
    return nil unless url != couchdb_url || Rails.env.test?
    response = conn_json.delete url
    (response.body["ok"] ? response.body["rev"] : nil)
  rescue *SourceHelperExceptions => e
    rescue_faraday_error(url, e, options)
  end

  def get_alm_database
    get_alm_data
  end

  def put_alm_database
    put_alm_data(couchdb_url)
  end

  def delete_alm_database
    delete_alm_data(couchdb_url)
  end

  def get_original_url(url, options = { timeout: DEFAULT_TIMEOUT })
    conn = conn_doi
    conn.options[:timeout] = options[:timeout]
    response = conn.head url
    response.env[:url].to_s
  rescue *SourceHelperExceptions => e
    rescue_faraday_error(url, e, options)
  end

  def save_to_file(url, filename = "tmpdata", options = { timeout: DEFAULT_TIMEOUT })
    conn = conn_xml
    conn.basic_auth(options[:username], options[:password]) if options[:username]
    conn.options[:timeout] = options[:timeout]
    response = conn.get url

    File.open("#{Rails.root}/data/#{filename}", 'w') { |file| file.write(response.body) }
    filename
  rescue *SourceHelperExceptions => e
    rescue_faraday_error(url, e, options.merge(:xml => true))
  rescue => exception
    ErrorMessage.create(:exception => exception, :class_name => exception.class.to_s,
                        :message => exception.message,
                        :status => 500,
                        :source_id => options[:source_id])
    nil
  end

  def conn_json
    Faraday.new do |c|
      c.headers['content-type'] = 'application/json'
      c.headers['User-agent'] = "#{APP_CONFIG['useragent']} - #{APP_CONFIG['hostname']}"
      c.request  :json
      c.response :json
      c.use      Faraday::Response::RaiseError
      c.adapter  Faraday.default_adapter
    end
  end

  def conn_xml
    Faraday.new do |c|
      c.headers['content-type'] = 'application/xml'
      c.headers['User-agent'] = "#{APP_CONFIG['useragent']} - #{APP_CONFIG['hostname']}"
      c.use      Faraday::Response::RaiseError
      c.adapter  Faraday.default_adapter
    end
  end

  def conn_doi
    Faraday.new do |c|
      c.headers['User-agent'] = "#{APP_CONFIG['useragent']} - #{APP_CONFIG['hostname']}"
      c.use     FaradayMiddleware::FollowRedirects, :limit => 10
      c.use     :cookie_jar
      c.use     Faraday::Response::RaiseError
      c.adapter Faraday.default_adapter
    end
  end

  def couchdb_url
    APP_CONFIG['couchdb_url']
  end

  def rescue_faraday_error(url, error, options={})
    if error.kind_of?(Faraday::Error::ResourceNotFound)
      if !error.response
        nil
      elsif options[:json]
        ActiveSupport::JSON.decode(error.response[:body])
      elsif options[:xml]
        Nokogiri::XML(error.response[:body])
      else
        error.response[:body]
      end
    else
      if error.kind_of?(Faraday::Error::TimeoutError)
        status = 408
      elsif error.respond_to?('status')
        status = error[:status]
      elsif error.respond_to?('response')
        status = error.response[:status].presence || 400
      else
        status = 400
      end

      if error.respond_to?('exception')
        exception = error.exception
      else
        exception = ""
      end

      class_name = error.class
      message = "#{error.message} for #{url}"

      case status
      when 400
        class_name = Net::HTTPBadRequest
      when 401
        class_name = Net::HTTPUnauthorized
      when 403
        class_name = Net::HTTPForbidden
      when 406
        class_name = Net::HTTPNotAcceptable
      when 408
        class_name = Net::HTTPRequestTimeOut
      when 409
        class_name = Net::HTTPConflict
        message = "#{error.message} with rev #{options[:data][:rev]}"
      when 429
        class_name = Net::HTTPClientError
      when 500
        class_name = Net::HTTPInternalServerError
      when 502
        class_name = Net::HTTPBadGateway
      when 503
        class_name = Net::HTTPServiceUnavailable
      end

      ErrorMessage.create(:exception => exception,
                          :class_name => class_name.to_s,
                          :message => message,
                          :status => status,
                          :target_url => url,
                          :source_id => options[:source_id])
      nil
    end
  end
end
