if Rails.env.development? and ENV['BYEBUGPORT']
  require 'byebug/core'
  Byebug.start_server 'localhost', ENV['BYEBUGPORT'].to_i
  puts "Starting Byebug server: localhost:#{ENV['BYEBUGPORT']}"
end
