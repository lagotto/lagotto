require 'resolv-replace.rb'

Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new { |exception, hash| Alert.create(exception: exception) }
  config.options[:concurrency] = ENV["CONCURRENCY"].to_i
end
