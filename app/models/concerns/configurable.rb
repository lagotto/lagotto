module Configurable
  extend ActiveSupport::Concern

  included do
    # List of field names for forms, strong_parameters and validations,
    # defined in subclassed sources
    def config_fields
      []
    end

    def url
      config.url
    end

    def url=(value)
      config.url = value
    end

    def events_url
      config.events_url
    end

    def events_url=(value)
      config.events_url = value
    end

    def feed_url
      config.feed_url
    end

    def feed_url=(value)
      config.feed_url = value
    end

    def username
      config.username
    end

    def username=(value)
      config.username = value
    end

    def password
      config.password
    end

    def password=(value)
      config.password = value
    end

    def openurl_username
      config.openurl_username
    end

    def openurl_username=(value)
      config.openurl_username = value
    end

    def api_key
      config.api_key
    end

    def api_key=(value)
      config.api_key = value
    end

    def api_secret
      config.api_secret
    end

    def api_secret=(value)
      config.api_secret = value
    end

    def client_id
      config.client_id
    end

    def client_id=(value)
      config.client_id = value
    end

    def client_secret
      config.client_secret
    end

    def client_secret=(value)
      config.client_secret = value
    end

    def expires_at
      config.expires_at || "1970-01-01"
    end

    def expires_at=(value)
      config.expires_at = value
    end

    def access_token
      config.access_token
    end

    def access_token=(value)
      config.access_token = value
    end

    def db_url
      config.db_url || "http://127.0.0.1:5984/#{name}/"
    end

    def db_url=(value)
      # make sure we have trailing slash
      config.db_url = value ? value.chomp("/") + "/" : nil
    end

    def authentication_url
      config.authentication_url
    end

    def authentication_url=(value)
      config.authentication_url = value
    end

    def journals
      config.journals
    end

    def journals=(value)
      config.journals = value
    end

    def languages
      # Default is 25 largest Wikipedias:
      # https://meta.wikimedia.org/wiki/List_of_Wikipedias#All_Wikipedias_ordered_by_number_of_works
      config.languages || "en nl de sv fr it ru es pl war ceb ja vi pt zh uk ca no fi fa id cs ko hu ar commons"
    end

    def languages=(value)
      config.languages = value
    end

    def count_limit
      config.count_limit || 20000
    end

    def count_limit=(value)
      config.count_limit = value
    end

    def disable_delay
      10
    end

    def timeout
      config.timeout || 30
    end

    def timeout=(value)
      config.timeout = value.to_i
    end

    def max_failed_queries
      config.max_failed_queries || 200
    end

    def max_failed_queries=(value)
      config.max_failed_queries = value.to_i
    end

    def max_failed_query_time_interval
      86400
    end

    def job_batch_size
      200
    end

    def rate_limiting
      config.rate_limiting || 200000
    end

    def rate_limiting=(value)
      config.rate_limiting = value.to_i
    end

    def job_interval
      3600 / rate_limiting
    end

    def batch_interval
      job_interval * job_batch_size
    end

    def batch_time_interval
      1.hour
    end

    # The update interval for works depends on work age. We use 4 different intervals that have default settings, but can also be configured individually per source:
    # * first week: update daily
    # * first month: update daily
    # * first year: update every ¼ month
    # * after one year: update monthly
    def staleness_week
      config.staleness_week || 1.day
    end

    def staleness_week=(value)
      config.staleness_week = value.to_i
    end

    def staleness_month
      config.staleness_month || 1.day
    end

    def staleness_month=(value)
      config.staleness_month = value.to_i
    end

    def staleness_year
      config.staleness_year || (1.month * 0.25).to_i
    end

    def staleness_year=(value)
      config.staleness_year = value.to_i
    end

    def staleness_all
      config.staleness_all || 1.month
    end

    def staleness_all=(value)
      config.staleness_all = value.to_i
    end

    def staleness
      [staleness_week, staleness_month, staleness_year, staleness_all]
    end

    def staleness_with_limits
      ["in the last 7 days", "in the last 31 days", "in the last year", "more than a year ago"].zip(staleness)
    end

    def cron_line
      config.cron_line || "* 4 * * *"
    end

    def cron_line=(value)
      config.cron_line = value
    end

    def queue
      config.queue || "default"
    end

    def queue=(value)
      config.queue = value
    end

    # is this source no longer accepting new data?
    def obsolete
      config.obsolete || false
    end

    def obsolete=(value)
      config.obsolete = value
    end

    alias_method :obsolete?, :obsolete

    # is this source using publisher-specific settings?
    def by_publisher
      config.by_publisher || false
    end

    def by_publisher=(value)
      config.by_publisher = value
    end

    alias_method :by_publisher?, :by_publisher

  end
end
