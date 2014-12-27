Lagotto::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  # See everything in the log (default is :info)
  log_level = ENV["LOG_LEVEL"] ? ENV["LOG_LEVEL"].to_sym : :info
  config.log_level = log_level

  # log to file, using logstash JSON format
  logstash_type = ENV["LOGSTASH_TYPE"] ? ENV["LOGSTASH_TYPE"].to_sym : :file
  config.logstash.type = logstash_type

  # Optional, Redis will default to localhost
  config.logstash.host = ENV["LOGSTASH_HOST"] || "localhost"

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :dalli_store, { :namespace => "alm" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Define custom exception handler
  config.exceptions_app = lambda { |env| AlertsController.action(:create).call(env) }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # for devise
  # TODO: Must set it with correct value!!
  config.action_mailer.default_url_options = { :host => "#{ENV['MAIL_ADDRESS']}:#{ENV['MAIL_PORT']}" }
end
