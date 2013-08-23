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
  SourceHelperExceptions = [Faraday::Error::ClientError].freeze

  def get_json(url, options = { timeout: DEFAULT_TIMEOUT })
    begin
      conn = conn_json
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.options[:timeout] = options[:timeout]
      response = conn.get url
      response.body
    rescue *SourceHelperExceptions => e
      rescue_faraday_error(url, e, options.merge(:json => true))
    end
  end

  def get_xml(url, options = { timeout: DEFAULT_TIMEOUT })
    begin
      conn = conn_xml
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.options[:timeout] = options[:timeout]
      response = conn.get url
      # We have issues with the Faraday XML parsing
      Nokogiri::XML(response.body)
    rescue *SourceHelperExceptions => e
      rescue_faraday_error(url, e, options.merge(:xml => true))
    end
  end

  def post_xml(url, data, options = { timeout: DEFAULT_TIMEOUT })
    begin
      conn = conn_xml
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.options[:timeout] = options[:timeout]
      response = conn.post url do |request|
        request.body = data
      end
      # We have issues with the Faraday XML parsing
      Nokogiri::XML(response.body)
    rescue *SourceHelperExceptions => e
      rescue_faraday_error(url, e, options.merge(:xml => true))
    end
  end

  def get_alm_data(id)
    get_json("#{couchdb_url}#{id}")
  end

  def save_alm_data(data_rev, data, id)
    # set the revision information
    unless data_rev.nil?
      data[:_id] = id
      data[:_rev] = data_rev
    end

    response = put_alm_data("#{couchdb_url}#{id}", data)
    return nil unless response
    response.body["rev"]
  end

  def put_alm_data(url, data)
    begin
      conn_json.put url do |request|
        request.body = data
      end
    rescue *SourceHelperExceptions => e
      rescue_faraday_error(couchdb_url, e)
    end
  end

  def remove_alm_data(data_rev, id)
    params = {'rev' => data_rev }

    response = delete_alm_data("#{couchdb_url}#{id}?#{params.to_query}")
    return nil unless response
    response.body["rev"]
  end

  def delete_alm_data(url)
    begin
      conn_json.delete url
    rescue *SourceHelperExceptions => e
      rescue_faraday_error(couchdb_url, e)
    end
  end

  def get_alm_database
    get_json(couchdb_url)
  end

  def put_alm_database
    return nil unless Rails.env.test?
    begin
      conn_json.put couchdb_url
    rescue *SourceHelperExceptions => e
      rescue_faraday_error(couchdb_url, e)
    end
  end

  def delete_alm_database
    return nil unless Rails.env.test?
    begin
      conn_json.delete couchdb_url
    rescue *SourceHelperExceptions => e
      rescue_faraday_error(couchdb_url, e)
    end
  end

  def get_original_url(url)
    begin
      conn = conn_doi
      conn.options[:timeout] = DEFAULT_TIMEOUT
      response = conn.head url
      response.env[:url].to_s
    rescue *SourceHelperExceptions => e
      rescue_faraday_error(url, e)
    end
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
      elsif error.response
        status = error.response[:status]
      else
        status = 400
      end
      ErrorMessage.create(:exception => "", :class_name => error.class.to_s,
                          :message => "#{error.message} for #{url}",
                          :status => status,
                          :source_id => options[:source_id])
      nil
    end
  end
end
