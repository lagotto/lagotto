module Adsable
  extend ActiveSupport::Concern

  included do
    def get_query_url(work, options = {})
      fail ArgumentError, "API key is missing." unless access_token.present?

      query_string = get_query_string(work)
      return {} unless query_string.present?

      params = { q: query_string,
                 start: 0,
                 rows: 100,
                 fl: "author,title,pubdate,identifier,doi",
                 access_token: access_token }
      url +  URI.encode_www_form(params)
    end

    def get_events_url(work, options = {})
      query_string = get_query_string(work)
      return {} unless query_string.present?

      Addressable::URI.encode(events_url % { query_string: query_string })
    end

    def parse_data(result, work, options={})
      return result if result[:error]

      related_works = get_related_works(result, work)
      total = related_works.length
      events_url = total > 0 ? get_events_url(work) : nil

      { works: related_works,
        events: {
          source: name,
          work: work.pid,
          total: total,
          events_url: events_url } }
    end

    def config_fields
      [:url, :events_url, :access_token]
    end

    def rate_limiting
      config.rate_limiting || 1000
    end
  end
end
