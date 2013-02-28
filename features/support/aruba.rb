require 'aruba/cucumber'
require 'webmock/cucumber'

WebMock.disable_net_connect!(:allow_localhost => true)

PROJECT_ROOT = File.join(File.dirname(__FILE__),'..','..')
ENV['PATH'] = "#{File.join(PROJECT_ROOT,'bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

Before do  
  # Set the defaults for Aruba
  @aruba_timeout_seconds = 90
  @aruba_io_wait_seconds = 5
end

Before('@slow_process') do
  @aruba_timeout_seconds = 900
end