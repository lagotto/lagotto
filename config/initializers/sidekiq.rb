Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new do |exception, hash|
    hash[:exception] = exception
    Alert.create(hash)
  end
end
