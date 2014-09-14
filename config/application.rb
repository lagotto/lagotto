require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'safe_yaml'
require 'socket'

SafeYAML::OPTIONS[:default_mode] = :safe
SafeYAML::OPTIONS[:deserialize_symbols] = true
SafeYAML::OPTIONS[:whitelisted_tags] = ["!ruby/object:OpenStruct"]

CONFIG = YAML.load(ERB.new(File.read(File.expand_path('../settings.yml', __FILE__))).result)[Rails.env]
CONFIG.symbolize_keys!

# reasonable defaults
CONFIG[:uid] ||= "doi"
CONFIG[:sitename] ||= "ALM"
CONFIG[:useragent] ||= "Lagotto"

addrinfo = Socket.getaddrinfo(Socket.gethostname, nil, nil, Socket::SOCK_DGRAM, nil, Socket::AI_CANONNAME)
CONFIG[:hostname] ||= addrinfo[0][2]
CONFIG[:public_server] ||= CONFIG[:hostname]
CONFIG[:web_servers] ||= [CONFIG[:hostname]]

if defined?(Bundler)
  # Require the gems listed in Gemfile, including any gems
  # you've limited to :test, :development, or :production.
  Bundler.require(:default, Rails.env)
end

module Lagotto
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/app/models/**/", "#{config.root}/app/controllers/**/"]

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

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # avoid mass-assignment
    config.active_record.whitelist_attributes = false

    # Configure sensitive parameters which will be filtered from the log file.
    # TODO: do I need to add salt here?
    config.filter_parameters += [:password]

    # Use a different cache store
    config.cache_store = :dalli_store, *CONFIG[:web_servers], { :namespace => "lagotto_#{Rails.env}", :compress => true }

    # Enable the asset pipeline
    config.assets.enabled = true

    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Define custom exception handler
    config.exceptions_app = lambda { |env| AlertsController.action(:create).call(env) }

    # Skip validation of locale
    I18n.enforce_available_locales = false

    # Disable IP spoofing check
    config.action_dispatch.ip_spoofing_check = false
  end
end
