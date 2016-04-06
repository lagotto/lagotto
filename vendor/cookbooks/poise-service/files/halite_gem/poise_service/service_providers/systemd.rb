#
# Copyright 2015-2016, Noah Kantrowitz
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

require 'chef/mixin/shell_out'

require 'poise_service/service_providers/base'


module PoiseService
  module ServiceProviders
    class Systemd < Base
      include Chef::Mixin::ShellOut
      provides(:systemd)

      # @api private
      def self.provides_auto?(node, resource)
        # Don't allow systemd under docker, it won't work in most cases.
        return false if node['virtualization'] && %w{docker lxc}.include?(node['virtualization']['system'])
        service_resource_hints.include?(:systemd)
      end

      # @api private
      def self.default_inversion_options(node, resource)
        super.merge({
          # Automatically reload systemd on changes.
          auto_reload: true,
          # Service restart mode.
          restart_mode: 'on-failure',
        })
      end

      def pid
        cmd = shell_out(%w{systemctl status} + [new_resource.service_name])
        if !cmd.error? && cmd.stdout.include?('Active: active (running)') && md = cmd.stdout.match(/Main PID: (\d+)/)
          md[1].to_i
        else
          nil
        end
      end

      private

      def service_resource
        super.tap do |r|
          r.provider(Chef::Provider::Service::Systemd)
        end
      end

      def systemctl_daemon_reload
        execute 'systemctl daemon-reload' do
          action :nothing
          user 'root'
        end
      end

      def create_service
        reloader = systemctl_daemon_reload
        service_template("/etc/systemd/system/#{new_resource.service_name}.service", 'systemd.service.erb') do
          notifies :run, reloader, :immediately if options['auto_reload']
          variables.update(auto_reload: options['auto_reload'], restart_mode: options['restart_mode'])
        end
      end

      def destroy_service
        file "/etc/systemd/system/#{new_resource.service_name}.service" do
          action :delete
        end
      end

    end
  end
end
