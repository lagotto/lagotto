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
  class Provider::FirewallIptables < Provider
    include Poise
    include Chef::Mixin::ShellOut

    def action_enable
      converge_by("install package #{package_name} and default DROP if no rules exist") do
        package package_name do
          action :install
        end

        service service_name do
          action [:enable, :start]
        end

        # prints all the firewall rules
        # pp new_resource.subresources
        log_current_iptables
        if active?
          Chef::Log.info("#{new_resource} already enabled.")
        else
          Chef::Log.debug("#{new_resource} is about to be enabled")
          shell_out!('iptables -P INPUT DROP')
          shell_out!('iptables -P OUTPUT DROP')
          shell_out!('iptables -P FORWARD DROP')

          shell_out!('ip6tables -P INPUT DROP')
          shell_out!('ip6tables -P OUTPUT DROP')
          shell_out!('ip6tables -P FORWARD DROP')
          Chef::Log.info("#{new_resource} enabled.")
          new_resource.updated_by_last_action(true)
        end
      end
    end

    def action_disable
      if active?
        shell_out!('iptables -P INPUT ACCEPT')
        shell_out!('iptables -P OUTPUT ACCEPT')
        shell_out!('iptables -P FORWARD ACCEPT')
        shell_out!('iptables -F')

        shell_out!('ip6tables -P INPUT ACCEPT')
        shell_out!('ip6tables -P OUTPUT ACCEPT')
        shell_out!('ip6tables -P FORWARD ACCEPT')
        shell_out!('ip6tables -F')
        Chef::Log.info("#{new_resource} disabled")
        new_resource.updated_by_last_action(true)
      else
        Chef::Log.debug("#{new_resource} already disabled.")
      end

      service service_name do
        action [:disable, :stop]
      end
    end

    def action_flush
      shell_out!('iptables -F')
      shell_out!('ip6tables -F')
      Chef::Log.info("#{new_resource} flushed.")
    end

    def action_save
      shell_out!("service #{service_name} save")
      # iptables-persistent does ipv6 inside the iptables init script
      shell_out!('service ip6tables save') unless ubuntu?
      Chef::Log.info("#{new_resource} saved.")
    end

    private

    def active?
      @active ||= begin
        cmd = shell_out!('iptables-save')
        cmd.stdout =~ /INPUT ACCEPT/
      end
      @active_v6 ||= begin
        cmd = shell_out!('ip6tables-save')
        cmd.stdout =~ /INPUT ACCEPT/
      end
      @active && @active_v6
    end

    def log_current_iptables
      cmdstr = 'iptables -L'
      Chef::Log.info("#{new_resource} log_current_iptables (#{cmdstr}):")
      cmd = shell_out!(cmdstr)
      Chef::Log.info(cmd.inspect)
      cmdstr = 'ip6tables -L'
      Chef::Log.info("#{new_resource} log_current_iptables (#{cmdstr}):")
      cmd = shell_out!(cmdstr)
      Chef::Log.info(cmd.inspect)
    rescue
      Chef::Log.info("#{new_resource} log_current_iptables failed!")
    end

    def package_name
      if ubuntu?
        'iptables-persistent'
      else
        'iptables'
      end
    end

    def service_name
      if ubuntu?
        'iptables-persistent'
      else
        'iptables'
      end
    end

    def ubuntu?
      node['platform'] == 'ubuntu'
    end
  end
end
