require 'resolv-replace.rb'

Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new do |exception, hash|
    Alert.where(message: exception.message).where(unresolved: true).first_or_create(exception: exception)
  end
  config.options[:concurrency] = ENV["CONCURRENCY"].to_i
end
