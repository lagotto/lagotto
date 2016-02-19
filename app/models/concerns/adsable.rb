module Adsable
  extend ActiveSupport::Concern

  included do
    def request_options
      { bearer: access_token }
    end

    def get_query_url(options = {})
      fail ArgumentError, "API key is missing." unless access_token.present?

      query_string = get_query_string(options)
      return {} unless query_string.present?

      params = { q: query_string,
                 start: 0,
                 rows: 100,
                 fl: "author,title,pubdate,identifier,doi" }
      url +  URI.encode_www_form(params)
    end

    def get_events_url(options = {})
      query_string = get_query_string(options)
      return {} unless query_string.present?

      Addressable::URI.encode(events_url % { query_string: query_string })
    end

    def config_fields
      [:url, :events_url, :access_token]
    end

    def rate_limiting
      config.rate_limiting || 1000
    end
  end
end
