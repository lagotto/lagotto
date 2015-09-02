#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: firewall
# Resource:: default
#
# Copyright:: 2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'poise'

class Chef
  class Provider::FirewallUfw < Provider
    include Poise
    include Chef::Mixin::ShellOut

    def action_enable
      converge_by('install ufw, template some defaults, and ufw enable') do
        package 'ufw' do
          action :nothing
        end.run_action(:install) # need this now if running in a provider

        template '/etc/default/ufw' do
          action [:create]
          owner 'root'
          group 'root'
          mode '0644'
          source 'ufw/default.erb'
          cookbook 'firewall'
          action :nothing
        end.run_action(:create) # need this now if running in a provider

        service 'ufw' do
          action [:enable, :start]
        end

        # new_resource.subresources contains all the firewall rules
        if active?
          Chef::Log.debug("#{new_resource} already enabled.")
        else
          shell_out!('ufw', 'enable', :input => 'yes')
          Chef::Log.info("#{new_resource} enabled")
          if new_resource.log_level
            shell_out!('ufw', 'logging', new_resource.log_level.to_s)
            Chef::Log.info("#{new_resource} logging enabled at '#{new_resource.log_level}' level")
          end
          new_resource.updated_by_last_action(true)
        end
      end
    end

    def action_disable
      if active?
        shell_out!('ufw', 'disable')
        Chef::Log.info("#{new_resource} disabled")
        new_resource.updated_by_last_action(true)
      else
        Chef::Log.debug("#{new_resource} already disabled.")
      end

      service 'ufw' do
        action [:disable, :stop]
      end
    end

    private

    def active?
      @active ||= begin
        cmd = shell_out!('ufw', 'status')
        cmd.stdout =~ /^Status:\sactive/
      end
    end
  end
end
