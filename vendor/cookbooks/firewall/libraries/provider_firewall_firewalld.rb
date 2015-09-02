#
# Author:: Ronald Doorn (<rdoorn@schubergphilis.com>)
# Cookbook Name:: firewall
# Resource:: default
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
  class Provider::FirewallFirewalld < Provider
    include Poise
    include Chef::Mixin::ShellOut

    def action_enable
      converge_by('install package firewalld and default DROP if no rules exist') do
        package 'firewalld' do
          action :install
        end

        # prints all the firewall rules
        # pp @new_resource.subresources
        log_current_firewalld

        service 'firewalld' do
          action [:enable, :start]
        end

        if active?
          Chef::Log.debug("#{@new_resource} already enabled.")
        else
          Chef::Log.debug("#{@new_resource} is about to be enabled")
          shell_out!('service', 'firewalld', 'start')
          shell_out!('firewall-cmd', '--set-default-zone=drop')
          Chef::Log.info("#{@new_resource} enabled.")
          new_resource.updated_by_last_action(true)
        end
      end
    end

    def action_disable
      if active?
        shell_out!('firewall-cmd', '--set-default-zone=public')
        shell_out!('firewall-cmd', '--direct', '--remove-rules', 'ipv4', 'filter', 'INPUT')
        shell_out!('firewall-cmd', '--direct', '--remove-rules', 'ipv4', 'filter', 'OUTPUT')
        Chef::Log.info("#{@new_resource} disabled")
        new_resource.updated_by_last_action(true)
      else
        Chef::Log.debug("#{@new_resource} already disabled.")
      end

      service 'firewalld' do
        action [:disable, :stop]
      end
    end

    def action_flush
      shell_out!('firewall-cmd', '--direct', '--remove-rules', 'ipv4', 'filter', 'INPUT')
      shell_out!('firewall-cmd', '--direct', '--remove-rules', 'ipv4', 'filter', 'OUTPUT')
      shell_out!('firewall-cmd', '--direct', '--permanent', '--remove-rules', 'ipv4', 'filter', 'INPUT')
      shell_out!('firewall-cmd', '--direct', '--permanent', '--remove-rules', 'ipv4', 'filter', 'OUTPUT')
      Chef::Log.info("#{@new_resource} flushed.")
    end

    def action_save
      if shell_out!('firewall-cmd', '--direct', '--get-all-rules').stdout != shell_out!('firewall-cmd', '--direct', '--permanent', '--get-all-rules').stdout
        shell_out!('firewall-cmd', '--direct', '--permanent', '--remove-rules', 'ipv4', 'filter', 'INPUT')
        shell_out!('firewall-cmd', '--direct', '--permanent', '--remove-rules', 'ipv4', 'filter', 'OUTPUT')
        shell_out!('firewall-cmd', '--direct', '--get-all-rules').stdout.lines do |line|
          shell_out!("firewall-cmd --direct --permanent --add-rule #{line}")
        end
        Chef::Log.info("#{@new_resource} saved.")
        new_resource.updated_by_last_action(true)
      else
        Chef::Log.info("#{@new_resource} already up-to-date.")
      end
    end

    private

    def active?
      @active ||= begin
        cmd = shell_out('firewall-cmd', '--state')
        cmd.stdout =~ /^running$/
      end
    end

    def log_current_firewalld
      cmdstr = 'firewall-cmd --direct --get-all-rules'
      Chef::Log.info("#{@new_resource} log_current_firewalld (#{cmdstr}):")
      cmd = shell_out!(cmdstr)
      Chef::Log.info(cmd.inspect)
    rescue
      Chef::Log.info("#{@new_resource} log_current_firewalld failed!")
    end
  end
end
