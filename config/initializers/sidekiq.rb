Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new { |exception, hash| Alert.create(exception: exception) }
end

log_level = ENV["LOG_LEVEL"] ? ENV["LOG_LEVEL"].to_sym : :info
Sidekiq::Logging.logger.level = log_level
