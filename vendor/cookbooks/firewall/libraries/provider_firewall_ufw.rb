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
class Chef
  class Provider::FirewallUfw < Chef::Provider::LWRPBase
    include FirewallCookbook::Helpers::Ufw

    provides :firewall, os: 'linux', platform_family: %w(debian) do |node|
      !(node['firewall'] && node['firewall']['ubuntu_iptables'])
    end

    def whyrun_supported?
      false
    end

    action :install do
      next if disabled?(new_resource)

      converge_by('install ufw, create template for /etc/default') do
        package 'ufw' do
          action :install
        end

        template '/etc/default/ufw' do
          action [:create]
          owner 'root'
          group 'root'
          mode '0644'
          source 'ufw/default.erb'
          cookbook 'firewall'
        end

        file "create empty #{ufw_rules_filename}" do
          path ufw_rules_filename
          content '# created by chef to allow service to start'
          not_if { ::File.exist?(ufw_rules_filename) }
        end
      end
    end

    action :restart do
      next if disabled?(new_resource)

      # ensure it's initialized
      new_resource.rules({}) unless new_resource.rules
      new_resource.rules['ufw'] = {} unless new_resource.rules['ufw']

      # this populates the hash of rules from firewall_rule resources
      firewall_rules = run_context.resource_collection.select { |item| item.is_a?(Chef::Resource::FirewallRule) }
      firewall_rules.each do |firewall_rule|
        next unless firewall_rule.action.include?(:create) && !firewall_rule.should_skip?(:create)

        # build rules to apply with weight
        k = build_rule(firewall_rule)
        v = firewall_rule.position

        # unless we're adding them for the first time.... bail out.
        unless new_resource.rules['ufw'].key?(k) && new_resource.rules['ufw'][k] == v
          new_resource.rules['ufw'][k] = v
        end
      end

      # ensure a file resource exists with the current ufw rules
      begin
        ufw_file = run_context.resource_collection.find(file: ufw_rules_filename)
      rescue
        ufw_file = file ufw_rules_filename do
          action :nothing
        end
      end
      ufw_file.content build_rule_file(new_resource.rules['ufw'])
      ufw_file.run_action(:create)

      # if the file was changed, restart iptables
      if ufw_file.updated_by_last_action?
        ufw_reset!
        ufw_logging!(new_resource.log_level) if new_resource.log_level

        new_resource.rules['ufw'].sort_by { |_k, v| v }.map { |k, _v| k }.each do |cmd|
          ufw_rule!(cmd)
        end

        # ensure it's enabled _after_ rules are inputted, to catch malformed rules
        ufw_enable! unless ufw_active?
        new_resource.updated_by_last_action(true)
      end
    end

    action :disable do
      next if disabled?(new_resource)

      file "create empty #{ufw_rules_filename}" do
        path ufw_rules_filename
        content '# created by chef to allow service to start'
      end

      if ufw_active?
        ufw_disable!
        new_resource.updated_by_last_action(true)
      end
    end

    action :flush do
      next if disabled?(new_resource)

      ufw_reset!
      new_resource.updated_by_last_action(true)

      file "create empty #{ufw_rules_filename}" do
        path ufw_rules_filename
        content '# created by chef to allow service to start'
      end
    end
  end
end
