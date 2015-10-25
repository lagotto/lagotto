module Configurable
  extend ActiveSupport::Concern

  included do
    # List of field names for forms, strong_parameters and validations,
    # defined in subclassed sources
    def config_fields
      []
    end

    def url_private
      config.url_private
    end

    def url_private=(value)
      config.url_private = value
    end

    def events_url
      config.events_url
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

    def url_db
      config.url_db || "http://127.0.0.1:5984/#{name}/"
    end

    def url_db=(value)
      # make sure we have trailing slash
      config.url_db = value ? value.chomp("/") + "/" : nil
    end

    def journals
      config.journals
    end

    def journals=(value)
      config.journals = value
    end

    def registration_agencies
      config.registration_agencies
    end

    def registration_agencies=(value)
      config.registration_agencies = value
    end

    def languages
      # Default is 25 largest Wikipedias:
      # https://meta.wikimedia.org/wiki/List_of_Wikipedias#All_Wikipedias_ordered_by_number_of_works
      # temporarily exclude ru because of an OpenSSL issue: https://github.com/lagotto/lagotto/issues/303
      config.languages || "en nl de sv fr it es pl war ceb ja vi pt zh uk ca no fi fa id cs ko hu ar commons"
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

    # store rate_limit_remaining and rate_limit_reset in memcached
    def rate_limit_remaining
      (Rails.cache.read("#{name}/rate_limit_remaining") || rate_limiting).to_i
    end

    def rate_limit_remaining=(value)
      value ||= rate_limit_reset > Time.zone.now ? rate_limit_remaining - 1 : rate_limiting
      Rails.cache.write("#{name}/rate_limit_remaining", value.to_i)
    end

    def rate_limit_reset
      Time.parse(Rails.cache.read("#{name}/rate_limit_reset") || (Time.zone.now.end_of_hour).utc.iso8601)
    end

    # reset rate_limit every full hour unless value is provided by source
    def rate_limit_reset=(value)
      value ||= (Time.zone.now.end_of_hour).to_i
      Rails.cache.write("#{name}/rate_limit_reset", get_iso8601_from_epoch(value))
    end

    def last_response
      Time.parse(Rails.cache.read("#{name}/last_response") || Time.zone.now.utc.iso8601)
    end

    def last_response=(value)
      value ||= (Time.zone.now).to_i
      Rails.cache.write("#{name}/last_response", get_iso8601_from_epoch(value))
    end

    def job_interval
      3600.0 / rate_limiting
    end

    def batch_interval
      job_interval * job_batch_size
    end

    def batch_time_interval
      1.hour
    end

    def cron_line
      config.cron_line || "* 4 1,8,15,22,29 * *"
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

    def tracked
      config.tracked || false
    end

    def tracked=(value)
      config.tracked = value
    end

    def only_publishers
      config.only_publishers || true
    end

    def only_publishers=(value)
      config.only_publishers = value
    end

    def sample
      config.sample
    end

    def sample=(value)
      config.sample = value
    end

    def source_id
      name
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
