if ENV["BUGSNAG_KEY"]
  Bugsnag.configure do |config|
    config.api_key = ENV["BUGSNAG_KEY"]
    config.hostname = ENV['BUGSNAG_HOSTNAME'] if ENV['BUGSNAG_HOSTNAME']
    config.release_stage = ENV['BUGSNAG_RELEASE_STAGE'] if ENV['BUGSNAG_RELEASE_STAGE']
    config.notify_release_stages = ["dev", "stage", "prod"]
  end
elsif ENV["SENTRY_KEY"]
  require 'raven'

  Raven.configure do |config|
    config.dsn = ENV["SENTRY_KEY"]
    config.environments = %w(stage production)
  end
end
