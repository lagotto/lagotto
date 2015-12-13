#
# Author:: Ronald Doorn (<rdoorn@schubergphilis.com>)
# Cookbook Name:: firewall
# Provider:: rule_iptables
#
# Copyright 2015, computerlyrik
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
  class Provider::FirewallRuleFirewalld < Chef::Provider::LWRPBase
    include FirewallCookbook::Helpers::Firewalld

    provides :firewall_rule, os: 'linux', platform_family: %w(rhel fedora) do |node|
      node['platform_version'].to_f >= 7.0 && !node['firewall']['redhat7_iptables']
    end

    action :create do
      firewall = run_context.resource_collection.find(firewall: new_resource.firewall_name)
      firewall.rules({}) unless firewall.rules
      firewall.rules['firewalld'] = {} unless firewall.rules['firewalld']
      next if disabled?(firewall)

      ip_versions(new_resource).each do |ip_version|
        # build rules to apply with weight
        k = "firewall-cmd --direct --add-rule #{build_firewall_rule(new_resource, ip_version)}"
        v = new_resource.position

        # unless we're adding them for the first time.... bail out.
        next if firewall.rules['firewalld'].key?(k) && firewall.rules['firewalld'][k] == v
        firewall.rules['firewalld'][k] = v

        # If persistent rules is enabled (default) make sure we add a permanent rule at the same time
        perm_rules = node && node['firewall'] && node['firewall']['firewalld'] && node['firewall']['firewalld']['permanent']
        if new_resource.permanent || perm_rules
          k = "firewall-cmd --permanent --direct --add-rule #{build_firewall_rule(new_resource, ip_version)}"
          firewall.rules['firewalld'][k] = v
        end
        new_resource.notifies(:restart, firewall, :delayed)
        new_resource.updated_by_last_action(true)
      end
    end
  end
end
