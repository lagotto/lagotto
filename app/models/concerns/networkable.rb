require 'faraday'
require 'faraday_middleware'
require 'net/http'
require 'excon'
require 'uri'

module Networkable
  extend ActiveSupport::Concern

  included do
    def get_result(url, options = { content_type: 'json' })
      conn = faraday_conn(options[:content_type], options)
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.authorization :Bearer, options[:bearer] if options[:bearer]
      conn.options[:timeout] = options[:timeout] || DEFAULT_TIMEOUT
      if options[:data]
        response = conn.post url, {}, options[:headers] do |request|
          request.body = options[:data]
        end
      else
        response = conn.get url, {}, options[:headers]
      end
      # set number of available API calls for sources
      if options[:source_id].present?
        source = Source.where(id: options[:source_id]).first
        source.update_attributes(rate_limit_remaining: get_rate_limit_remaining(response.headers),
                                 rate_limit_reset: get_rate_limit_reset(response.headers),
                                 last_reponse: Time.zone.now)
      end
      # parsing by content type is not reliable, so we check the response format
      if is_json?(response.body)
        JSON.parse(response.body)
      elsif is_xml?(response.body)
        Hash.from_xml(response.body)
      else
        response.body
      end
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def save_to_file(url, filename = "tmpdata", options = { content_type: 'xml' })
      conn = faraday_conn(options[:content_type], options)
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.options[:timeout] = options[:timeout] || DEFAULT_TIMEOUT
      response = conn.get url

      File.open("#{Rails.root}/data/#{filename}", 'w') { |file| file.write(response.body) }
      filename
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    rescue => exception
      options[:level] = Alert::FATAL
      create_alert(exception, options)
    end

    def read_from_file(filename = "tmpdata", options = { content_type: 'xml' })
      file = File.open("#{Rails.root}/data/#{filename}", 'r') { |f| f.read }
      if options[:content_type] == "json"
        JSON.parse(file)
      else
        Hash.from_xml(file)
      end
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    rescue => exception
      options[:level] = Alert::FATAL
      create_alert(exception, options)
    end

    def faraday_conn(content_type = 'json', options = {})
      content_types = { "html" => 'text/html; charset=UTF-8',
                        "xml" => 'application/xml',
                        "json" => 'application/json' }
      accept_header = content_types.fetch(content_type, 'application/json')
      limit = options[:limit] || 10

      Faraday.new do |c|
        c.headers['Accept'] = accept_header
        c.headers['User-Agent'] = "Lagotto #{Lagotto::VERSION} - http://#{ENV['SERVERNAME']}"
        c.use      FaradayMiddleware::FollowRedirects, limit: limit, cookie: :all
        c.request  :multipart
        c.request  :json if accept_header == 'application/json'
        c.use      Faraday::Response::RaiseError
        c.adapter  Faraday.default_adapter
      end
    end

    def rescue_faraday_error(url, error, options={})
      if error.is_a?(Faraday::ResourceNotFound)
        not_found_error(url, error, options)
      else
        details = nil
        headers = {}

        if error.is_a?(Faraday::Error::TimeoutError)
          status = 408
        elsif error.respond_to?('status')
          status = error[:status]
        elsif error.respond_to?('response') && error.response.present?
          status = error.response[:status]
          details = error.response[:body]
          headers = error.response[:headers]
        else
          status = 400
        end

        # Some sources use a different status for rate-limiting errors
        status = 429 if status == 403 && details.include?("Excessive use detected")

        if error.respond_to?('exception')
          exception = error.exception
        else
          exception = ""
        end

        class_name = class_name_by_status(status) || error.class
        level = level_by_status(status)

        message = parse_error_response(error.message)
        message = "#{message} for #{url}"
        message = "#{message} with rev #{options[:data][:rev]}" if class_name == Net::HTTPConflict
        message = "#{message}. Rate-limit #{get_rate_limit_limit(headers)} exceeded." if class_name == Net::HTTPTooManyRequests

        Alert.where(message: message).where(unresolved: true).first_or_create(
          exception: exception,
          class_name: class_name.to_s,
          details: details,
          status: status,
          target_url: url,
          level: level,
          work_id: options[:work_id],
          source_id: options[:source_id])

        { error: message, status: status }
      end
    end

    def not_found_error(url, error, options={})
      status = 404
      # we raise an error if we find a canonical URL mismatch
      # or a DOI can't be resolved
      if options[:doi_mismatch] || options[:doi_lookup]
        work = Work.where(id: options[:work_id]).first
        if options[:doi_mismatch]
          message = error.response[:message]
        else
          message = "DOI #{work.doi} could not be resolved"
        end
        Alert.where(message: message).where(unresolved: true).first_or_create(
          exception: error.exception,
          class_name: "Net::HTTPNotFound",
          details: error.response[:body],
          status: status,
          work_id: work.id,
          target_url: url)
        { error: message, status: status }
      else
        if error.response.blank? && error.response[:body].blank?
          message = "resource not found"
        else
          message = parse_error_response(error.response[:body])
        end
        { error: message, status: status }
      end
    end

    def class_name_by_status(status)
      { 400 => Net::HTTPBadRequest,
        401 => Net::HTTPUnauthorized,
        403 => Net::HTTPForbidden,
        404 => Net::HTTPNotFound,
        406 => Net::HTTPNotAcceptable,
        408 => Net::HTTPRequestTimeOut,
        409 => Net::HTTPConflict,
        417 => Net::HTTPExpectationFailed,
        429 => Net::HTTPTooManyRequests,
        500 => Net::HTTPInternalServerError,
        502 => Net::HTTPBadGateway,
        503 => Net::HTTPServiceUnavailable,
        504 => Net::HTTPGatewayTimeOut }.fetch(status, nil)
    end

    def level_by_status(status)
      level =
        case status
        # temporary network problems should be WARN not ERROR
        when 408, 502, 503, 504 then 2
        else 3
        end
    end

    # currently supported by twitter, github, ads and ads_fulltext
    # sources with slightly different header names
    def get_rate_limit_remaining(headers)
      headers["X-Rate-Limit-Remaining"] || headers["X-RateLimit-Remaining"]
    end

    def get_rate_limit_limit(headers)
      headers["X-Rate-Limit-Limit"] || headers["X-RateLimit-Limit"]
    end

    def get_rate_limit_reset(headers)
      headers["X-Rate-Limit-Reset"] || headers["X-RateLimit-Reset"]
    end

    def parse_error_response(string)
      if is_json?(string)
        string = JSON.parse(string)
      elsif is_xml?(string)
        string = Hash.from_xml(string)
      end
      string = string['error'] if string.is_a?(Hash) && string['error']
      string
    end

    def is_xml?(string)
      Nokogiri::XML(string).errors.empty?
    end

    def is_json?(string)
      JSON.parse(string)
    rescue JSON::ParserError
      false
    end

    def create_alert(exception, options = {})
      Alert.where(message: exception.message).where(unresolved: true).first_or_create(
        :exception => exception,
        :class_name => exception.class.to_s,
        :status => options[:status] || 500,
        :level => options[:level],
        :source_id => options[:source_id])
      nil
    end
  end
end
