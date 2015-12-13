#
# Author:: Martin Smith (<martin@mbs3.org>)
# Cookbook Name:: firewall
# Provider:: rule_iptables
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
  class Provider::FirewallRuleIptablesUbuntu < Chef::Provider::LWRPBase
    include FirewallCookbook::Helpers::Iptables

    provides :firewall_rule, os: 'linux', platform_family: %w(debian) do |node|
      node['firewall'] && node['firewall']['ubuntu_iptables']
    end

    action :create do
      if ipv6_rule?(new_resource) # an ip4 specific rule
        types = %w(ip6tables)
      elsif ipv4_rule?(new_resource) # an ip6 specific rule
        types = %w(iptables)
      else # or not specific
        types = %w(iptables ip6tables)
      end

      firewall = run_context.resource_collection.find(firewall: new_resource.firewall_name)
      firewall.rules({}) unless firewall.rules
      ensure_default_rules_exist(node, firewall)

      if firewall.disabled
        Chef::Log.warn("#{firewall} has attribute 'disabled' = true, not proceeding")
        next
      end

      types.each do |iptables_type|
        # build rules to apply with weight
        k = build_firewall_rule(node, new_resource, iptables_type == 'ip6tables')
        v = new_resource.position

        # unless we're adding them for the first time.... bail out.
        next if firewall.rules[iptables_type].key?(k) && firewall.rules[iptables_type][k] == v

        firewall.rules[iptables_type][k] = v
        new_resource.notifies(:restart, firewall, :delayed)
        new_resource.updated_by_last_action(true)
      end
    end
  end
end
