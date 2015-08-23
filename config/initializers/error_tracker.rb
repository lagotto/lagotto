if ENV["BUGSNAG_KEY"]
  Bugsnag.configure do |config|
    config.api_key = ENV["BUGSNAG_KEY"]
    config.notify_release_stages = %w(stage production)
  end
elsif ENV["SENTRY_KEY"]
  require 'raven'

  Raven.configure do |config|
    config.dsn = ENV["SENTRY_KEY"]
    config.environments = %w(stage production)
  end
end
