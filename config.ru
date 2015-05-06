# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require './lib/heartbeat'

map "/heartbeat" do
  run Heartbeat
end

map "/" do
  run Lagotto::Application
end
