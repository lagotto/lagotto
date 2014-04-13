# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
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
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'uri'

module Networkable
  extend ActiveSupport::Concern

  included do

    def get_json(url, options = { timeout: DEFAULT_TIMEOUT })
      conn = conn_json
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.authorization :Bearer, options[:bearer] if options[:bearer]
      conn.options[:timeout] = options[:timeout]
      if options[:data]
        response = conn.post url, {}, options[:headers] do |request|
          request.body = options[:data]
        end
      else
        response = conn.get url, {}, options[:headers]
      end
      response.body
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options.merge(json: true))
    end

    def post_json(url, options = { data: nil, timeout: DEFAULT_TIMEOUT })
      get_json(url, options)
    end

    def get_xml(url, options = { timeout: DEFAULT_TIMEOUT })
      conn = conn_xml
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.authorization :Bearer, options[:bearer] if options[:bearer]
      conn.options[:timeout] = options[:timeout]
      if options[:data]
        response = conn.post url, {}, options[:headers] do |request|
          request.body = options[:data]
        end
      else
        response = conn.get url, {}, options[:headers]
      end
      # We have issues with the Faraday XML parsing
      Nokogiri::XML(response.body)
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options.merge(xml: true))
    end

    def post_xml(url, options = { data: nil, timeout: DEFAULT_TIMEOUT })
      get_xml(url, options)
    end

    def get_html(url, options = { timeout: DEFAULT_TIMEOUT })
      conn = conn_html
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.options[:timeout] = options[:timeout]
      response = conn.get url, {}, options[:headers]
      response.body
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options.merge(html: true))
    end

    def save_to_file(url, filename = "tmpdata", options = { timeout: DEFAULT_TIMEOUT })
      conn = conn_xml
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.options[:timeout] = options[:timeout]
      response = conn.get url

      File.open("#{Rails.root}/data/#{filename}", 'w') { |file| file.write(response.body) }
      filename
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options.merge(:xml => true))
    rescue => exception
      Alert.create(:exception => exception,
                   :class_name => exception.class.to_s,
                   :message => exception.message,
                   :status => 500,
                   :source_id => options[:source_id])
      nil
    end

    def conn_json
      Faraday.new do |c|
        c.headers['Accept'] = 'application/json'
        c.headers['User-Agent'] = "#{CONFIG[:useragent]} - http://#{CONFIG[:hostname]}"
        c.use      Faraday::HttpCache, store: Rails.cache
        c.use      FaradayMiddleware::FollowRedirects, :limit => 10
        c.request  :multipart
        c.request  :json
        c.response :json, :content_type => /\bjson$/
        c.use      Faraday::Response::RaiseError
        c.adapter  Faraday.default_adapter
      end
    end

    def conn_xml
      Faraday.new do |c|
        c.headers['Accept'] = 'application/xml'
        c.headers['User-Agent'] = "#{CONFIG[:useragent]} - http://#{CONFIG[:hostname]}"
        c.use      Faraday::HttpCache, store: Rails.cache
        c.use      FaradayMiddleware::FollowRedirects, :limit => 10
        c.use      Faraday::Response::RaiseError
        c.adapter  Faraday.default_adapter
      end
    end

    def conn_html
      Faraday.new do |c|
        c.headers['Accept'] = 'text/html;charset=UTF-8'
        c.headers['Accept-Charset'] = 'UTF-8'
        c.headers['User-Agent'] = "#{CONFIG[:useragent]} - http://#{CONFIG[:hostname]}"
        c.use      Faraday::HttpCache, store: Rails.cache
        c.use      FaradayMiddleware::FollowRedirects, :limit => 10
        c.use      :cookie_jar
        c.use      Faraday::Response::RaiseError
        c.adapter  Faraday.default_adapter
      end
    end

    def rescue_faraday_error(url, error, options={})
      if error.kind_of?(Faraday::Error::ResourceNotFound)
        if error.response.blank? && error.response[:body].blank?
          nil
        elsif options[:doi_lookup]
          # we raise an error if a DOI can't be resolved
          # This is different from other 404 errors
          Alert.create(exception: error.exception,
                       class_name: error.class.to_s,
                       message: "DOI could not be resolved",
                       details: error.response[:body],
                       status: error.response[:status],
                       target_url: url)
          nil
        elsif options[:json]
          error.response[:body]
        elsif options[:xml]
          Nokogiri::XML(error.response[:body])
        elsif options[:html]
          error.response[:body]
        else
          error.response[:body]
        end
      # malformed JSON is treated as ResourceNotFound
      elsif error.message.include?("unexpected token")
        nil
      else
        details = nil

        if error.kind_of?(Faraday::Error::TimeoutError)
          status = 408
        elsif error.respond_to?('status')
          status = error[:status]
        elsif error.respond_to?('response') && error.response.present?
          status = error.response[:status]
          details = error.response[:body]
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
        when 417
          class_name = Net::HTTPExpectationFailed
        when 429
          class_name = Net::HTTPClientError
        when 500
          class_name = Net::HTTPInternalServerError
        when 502
          class_name = Net::HTTPBadGateway
        when 503
          class_name = Net::HTTPServiceUnavailable
        end

        Alert.create(exception: exception,
                     class_name: class_name.to_s,
                     message: message,
                     details: details,
                     status: status,
                     target_url: url,
                     source_id: options[:source_id])
        nil
      end
    end
  end
end
