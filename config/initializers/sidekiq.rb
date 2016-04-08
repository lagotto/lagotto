require 'resolv-replace.rb'

Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new do |exception, hash|
    unless ["ActiveRecord::RecordNotFound",
            "ActionController::RoutingError",
            "CustomError::TooManyRequestsError"].include?(exception.class.to_s)
      Notification.where(message: exception.message).where(unresolved: true).first_or_create(exception: exception)
    end
  end
  config.options[:concurrency] = ENV["CONCURRENCY"].to_i
end

if ["production", "stage"].include? ENV['RAILS_ENV']
  Sidekiq::Logging.logger = Syslog::Logger.new(ENV['APPLICATION'])
end
Sidekiq::Logging.logger.level = Logger.const_get(ENV["LOG_LEVEL"].upcase)
