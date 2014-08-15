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

module Couchable
  extend ActiveSupport::Concern

  included do

    def couchdb_url
      CONFIG[:couchdb_url]
    end

    def get_alm_data(id = "", options={})
      get_result("#{couchdb_url}#{id}", options)
    end

    def get_alm_rev(id, options={})
      head_alm_data("#{couchdb_url}#{id}", options)[:rev]
    end

    def head_alm_data(url, options = { timeout: DEFAULT_TIMEOUT })
      conn = faraday_conn('json')
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.options[:timeout] = options[:timeout]
      response = conn.head url

      # CouchDB revision is in etag header. We need to remove extra double quotes
      { rev: response.env[:response_headers][:etag][1..-2] }
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options.merge(head: true))
    end

    def save_alm_data(id, options = { data: nil })
      data_rev = get_alm_rev(id)
      if data_rev.present?
        options[:data][:_id] = "#{id}"
        options[:data][:_rev] = data_rev
      end

      put_alm_data("#{couchdb_url}#{id}", options)
    end

    def put_alm_data(url, options = { data: nil })
      return nil unless options[:data] || Rails.env.test?

      conn = faraday_conn('json')
      conn.options[:timeout] = DEFAULT_TIMEOUT
      response = conn.put url do |request|
        request.body = options[:data]
      end

      parse_rev(response.body)
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def remove_alm_data(id)
      data_rev = get_alm_rev(id)
      timestamp = Time.zone.now.utc.iso8601

      if data_rev.present?
        params = {'rev' => data_rev }
        response = delete_alm_data("#{couchdb_url}#{id}?#{params.to_query}")
      else
        response = nil
      end

      if response.nil?
        Rails.logger.info "#{timestamp}: CouchDB document #{id} not found"
      elsif response.respond_to?(:error)
        Rails.logger.error "#{timestamp}: CouchDB document #{id} could not be deleted: #{response[:error]}"
      else
        Rails.logger.info "#{timestamp}: CouchDB document #{id} deleted with rev #{response}"
      end

      response
    end

    def delete_alm_data(url, options={})
      # don't delete database
      return nil if (url == couchdb_url && Rails.env != "test")

      conn = faraday_conn('json')
      response = conn.delete url

      parse_rev(response.body)
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def get_alm_database
      get_alm_data
    end

    def put_alm_database
      put_alm_data(couchdb_url)
      filter = Faraday::UploadIO.new('design_doc/filter.json', 'application/json')
      put_alm_data("#{couchdb_url}_design/filter", data: filter)

      reports = Faraday::UploadIO.new('design_doc/reports.json', 'application/json')
      put_alm_data("#{couchdb_url}_design/reports", data: reports)
    end

    def delete_alm_database
      delete_alm_data(couchdb_url)
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
