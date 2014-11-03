$stdout.sync = true

Lagotto::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # config.assets.prefix = "/dev-assets"

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Expands the lines which load the assets
  config.assets.debug = true
  config.assets.raise_runtime_errors = true

  # for devise
  config.action_mailer.default_url_options = { :host => "#{ENV['MAIL_ADDRESS']}:#{ENV['MAIL_PORT']}" }
end
