module Couchable
  extend ActiveSupport::Concern

  included do
    def get_lagotto_data(url, options={})
      get_result(url, options)
    end

    def get_lagotto_rev(url, options={})
      head_lagotto_data(url, options)[:rev]
    end

    def head_lagotto_data(url, options = { timeout: DEFAULT_TIMEOUT })
      conn = faraday_conn('json', options)
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.options[:timeout] = options[:timeout]
      response = conn.head url

      # CouchDB revision is in etag header. We need to remove extra double quotes
      { rev: response.env[:response_headers][:etag][1..-2] }
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options.merge(head: true))
    end

    def save_lagotto_data(url, options = { data: nil })
      data_rev = get_lagotto_rev(url)
      if data_rev.present?
        options[:data][:_rev] = data_rev
      end

      put_lagotto_data(url, options)
    end

    def put_lagotto_data(url, options = { data: nil })
      return nil unless options[:data] || Rails.env.test?

      conn = faraday_conn('json', options)
      conn.options[:timeout] = DEFAULT_TIMEOUT
      response = conn.put url do |request|
        request.body = options[:data]
      end

      parse_rev(response.body)
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def remove_lagotto_data(url)
      data_rev = get_lagotto_rev(url)
      timestamp = Time.zone.now.utc.iso8601

      if data_rev.present?
        params = {'rev' => data_rev }
        response = delete_lagotto_data("#{url}?#{params.to_query}")
      else
        response = nil
      end

      if response.nil?
        Rails.logger.warn "#{timestamp}: CouchDB document #{url} not found"
      elsif response.respond_to?(:error)
        Rails.logger.error "#{timestamp}: CouchDB document #{url} could not be deleted: #{response[:error]}"
      else
        Rails.logger.info "#{timestamp}: CouchDB document #{url} deleted with rev #{response}"
      end

      response
    end

    def delete_lagotto_data(url, options={})
      # don't delete database
      return nil if Rails.env != "test"

      conn = faraday_conn('json', options)
      response = conn.delete url

      parse_rev(response.body)
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def parse_rev(string)
      if is_json?(string)
        json = JSON.parse(string)
        json['ok'] ? json['rev'] : nil
      else
        { error: 'malformed JSON response' }
      end
    end
  end
end
