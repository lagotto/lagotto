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

require 'poise_service/service_providers/base'


module PoiseService
  module ServiceProviders
    class Sysvinit < Base
      provides(:sysvinit)

      def self.provides_auto?(node, resource)
        [:debian, :redhat, :invokercd].any? {|name| service_resource_hints.include?(name) }
      end

      def pid
        IO.read(pid_file).to_i if ::File.exist?(pid_file)
      end

      private

      def service_resource
        super.tap do |r|
          r.provider(case node['platform_family']
          when 'debian'
            Chef::Provider::Service::Debian
          when 'rhel'
            Chef::Provider::Service::Redhat
          else
            # This will explode later in the template, but better than nothing for later.
            Chef::Provider::Service::Init
          end)
          r.init_command(script_path)
        end
      end

      def create_service
        # Split the command into the binary and its arguments. This is for
        # start-stop-daemon since it treats those differently.
        parts = new_resource.command.split(/ /, 2)
        daemon = ENV['PATH'].split(/:/)
          .map {|path| ::File.absolute_path(parts[0], path) }
          .find {|path| ::File.exist?(path) } || parts[0]
        # Sigh scoping.
        pid_file_ = pid_file
        # Render the service template
        service_template(script_path, 'sysvinit.sh.erb') do
          mode '755'
          variables.update(
            daemon: daemon,
            daemon_options: parts[1].to_s,
            pid_file: pid_file_,
            pid_file_external: !!options['pid_file'],
            platform_family: node['platform_family'],
          )
        end
      end

      def destroy_service
        file script_path do
          action :delete
        end

        file pid_file do
          action :delete
        end
      end

      def script_path
        options['script_path'] || "/etc/init.d/#{new_resource.service_name}"
      end

      def pid_file
        options['pid_file'] || "/var/run/#{new_resource.service_name}.pid"
      end
    end
  end
end
