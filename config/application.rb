require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'safe_yaml'

SafeYAML::OPTIONS[:default_mode] = :safe
SafeYAML::OPTIONS[:deserialize_symbols] = true
SafeYAML::OPTIONS[:whitelisted_tags] = ["!ruby/object:OpenStruct"]

if defined?(Bundler)
  # Require the gems listed in Gemfile, including any gems
  # you've limited to :test, :development, or :production.
  Bundler.require(:default, Rails.env)
end

# load ENV variables from .env file if it exists
env_file = File.expand_path("../../.env", __FILE__)
if File.exist?(env_file)
  require 'dotenv'
  Dotenv.load! env_file
end

# load ENV variables from container environment if json file exists
# see https://github.com/phusion/baseimage-docker#envvar_dumps
env_json_file = "/etc/container_environment.json"
if File.exist?(env_json_file)
  env_vars = JSON.parse(File.read(env_json_file))
  env_vars.each { |k, v| ENV[k] = v }
end

# default values for some ENV variables
ENV['APPLICATION'] ||= "lagotto"
ENV['SITENAMELONG'] ||= "Lagotto"
ENV['LOG_LEVEL'] ||= "info"
ENV['GITHUB_URL'] ||= "https://github.com/lagotto/lagotto"
ENV['TRUSTED_IP'] ||= "10.0.10.1"

module Lagotto
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/app/models/**/**", "#{config.root}/app/controllers/**/"]

    # add npm assets
    config.assets.paths << "#{Rails.root}/vendor/bower_components"

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    # TODO: do I need to add salt here?
    config.filter_parameters += [:password, :authentication_token]

    # Use a different cache store
    # dalli uses ENV['MEMCACHE_SERVERS']
    ENV['MEMCACHE_SERVERS'] ||= ENV['HOSTNAME']
    config.cache_store = :dalli_store, nil, { :namespace => ENV['APPLICATION'], :compress => true }

    # Skip validation of locale
    I18n.enforce_available_locales = false

    # Disable IP spoofing check
    config.action_dispatch.ip_spoofing_check = false

    # compress responses with deflate or gzip
    config.middleware.use Rack::Deflater

    # set Active Job queueing backend
    config.active_job.queue_adapter = :sidekiq

    # Minimum Sass number precision required by bootstrap-sass
    #::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max
  end
end
