Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new { |exception, hash| Alert.create(exception, hash) }
end
