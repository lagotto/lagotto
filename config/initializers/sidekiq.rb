require 'resolv-replace.rb'

Sidekiq.configure_server do |config|
  config.options[:concurrency] = ENV["CONCURRENCY"].to_i
end

Sidekiq::Logging.logger = Syslog::Logger.new(ENV['APPLICATION'])
Sidekiq::Logging.logger.level = Logger.const_get(ENV["LOG_LEVEL"].upcase)
