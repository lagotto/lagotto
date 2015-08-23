#
# Copyright 2015, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/resource'
require 'chef/provider'
require 'poise'


module PoiseService
  module Resources
    # (see PoiseServiceTest::Resource)
    module PoiseServiceTest
      # A `poise_service_test` resource for integration testing service providers.
      # This is used in Test-Kitchen tests to ensure all providers behave
      # similarly.
      #
      # @since 1.0.0
      # @provides poise_service_test
      # @action run
      # @example
      #   poise_service_test 'upstart' do
      #     service_provider :upstart
      #     base_port 5000
      #   end
      class Resource < Chef::Resource
        include Poise
        provides(:poise_service_test)
        actions(:run)

        # @!attribute service_provider
        #   Service provider to set for the test group.
        #   @return [Symbol]
        attribute(:service_provider, kind_of: Symbol)
        # @!attribute base_port
        #   Port number to start from for the test group.
        #   @return [Integer]
        attribute(:base_port, kind_of: Integer)
      end

      # Provider for `poise_service_test`.
      #
      # @see Resource
      # @provides poise_service_test
      class Provider < Chef::Provider
        include Poise
        provides(:poise_service_test)

        SERVICE_SCRIPT = <<-EOH
require 'webrick'
require 'json'
require 'etc'
FILE_DATA = ''
server = WEBrick::HTTPServer.new(Port: ARGV[0].to_i)
server.mount_proc '/' do |req, res|
  res.body = {
    directory: Dir.getwd,
    user: Etc.getpwuid(Process.uid).name,
    group: Etc.getgrgid(Process.gid).name,
    environment: ENV.to_hash,
    file_data: FILE_DATA,
    pid: Process.pid,
  }.to_json
end
EOH

        # `run` action for `poise_service_test`. Create all test services.
        #
        # @return [void]
        def action_run
          notifying_block do
            create_script
            create_noterm_script
            create_user
            create_tests
          end
        end

        private

        def create_script
          file '/usr/bin/poise_test' do
            owner 'root'
            group 'root'
            mode '755'
            content <<-EOH
#!/opt/chef/embedded/bin/ruby
#{SERVICE_SCRIPT}
def load_file
  FILE_DATA.replace(IO.read(ARGV[1]))
end
if ARGV[1]
  load_file
  trap('HUP') do
    load_file
  end
end
server.start
EOH
          end
        end

        def create_noterm_script
          file '/usr/bin/poise_test_noterm' do
            owner 'root'
            group 'root'
            mode '755'
            content <<-EOH
#!/opt/chef/embedded/bin/ruby
trap('HUP', 'IGNORE')
trap('STOP', 'IGNORE')
trap('TERM', 'IGNORE')
#{SERVICE_SCRIPT}
while true
  begin
    server.start
  rescue Exception
  rescue StandardError
  end
end
EOH
          end
        end

        def create_user
          poise_service_user 'poise' do
            home '/tmp'
          end
        end

        def create_tests
          poise_service "poise_test_#{new_resource.name}" do
            provider new_resource.service_provider if new_resource.service_provider
            command "/usr/bin/poise_test #{new_resource.base_port}"
          end

          poise_service "poise_test_#{new_resource.name}_params" do
            provider new_resource.service_provider if new_resource.service_provider
            command "/usr/bin/poise_test #{new_resource.base_port + 1}"
            environment POISE_ENV: new_resource.name
            user 'poise'
          end

          poise_service "poise_test_#{new_resource.name}_noterm" do
            provider new_resource.service_provider if new_resource.service_provider
            action [:enable, :disable]
            command "/usr/bin/poise_test_noterm #{new_resource.base_port + 2}"
            stop_signal 'kill'
          end

          {'restart' => 3, 'reload' => 4}.each do |action, port|
            # Stop it before writing the file so we always start with first.
            poise_service "poise_test_#{new_resource.name}_#{action} stop" do
              provider new_resource.service_provider if new_resource.service_provider
              action(:disable)
              service_name "poise_test_#{new_resource.name}_#{action}"
            end

            # Write the content to the read on service launch.
            file "/etc/poise_test_#{new_resource.name}_#{action}" do
              content 'first'
            end

            # Launch the service, reading in first.
            poise_service "poise_test_#{new_resource.name}_#{action}" do
              provider new_resource.service_provider if new_resource.service_provider
              command "/usr/bin/poise_test #{new_resource.base_port + port} /etc/poise_test_#{new_resource.name}_#{action}"
            end

            # Rewrite the file to second, restart/reload to trigger an update.
            file "/etc/poise_test_#{new_resource.name}_#{action} again" do
              path "/etc/poise_test_#{new_resource.name}_#{action}"
              content 'second'
              notifies action.to_sym, "poise_service[poise_test_#{new_resource.name}_#{action}]"
            end
          end

          ruby_block "/tmp/poise_test_#{new_resource.name}_pid" do
            block do
              pid = resources("poise_service[poise_test_#{new_resource.name}]").pid
              IO.write("/tmp/poise_test_#{new_resource.name}_pid", pid.to_s)
            end
          end
        end
      end
    end
  end
end
