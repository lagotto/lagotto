require 'aruba/cucumber'
require 'webmock/cucumber'

WebMock.disable_net_connect!(:allow_localhost => true)

Before do  
  # Set the defaults for Aruba
  @aruba_timeout_seconds = 90
  @aruba_io_wait_seconds = 5
end

Before('@slow_process') do
  @aruba_timeout_seconds = 300
end