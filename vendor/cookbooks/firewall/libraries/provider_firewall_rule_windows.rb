#
# Author:: Sander van Harmelen (<svanharmelen@schubergphilis.com>)
# Cookbook Name:: firewall
# Provider:: rule_windows
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
#
class Chef
  class Provider::FirewallRuleWindows < Chef::Provider::LWRPBase
    include FirewallCookbook::Helpers::Windows

    provides :firewall_rule, os: 'windows'

    action :create do
      firewall = run_context.resource_collection.find(firewall: new_resource.firewall_name)
      firewall.rules({}) unless firewall.rules
      firewall.rules['windows'] = {} unless firewall.rules['windows']

      if firewall.disabled
        Chef::Log.warn("#{firewall} has attribute 'disabled' = true, not proceeding")
        next
      end

      # build rules to apply with weight
      k = build_rule(new_resource)
      v = new_resource.position

      # unless we're adding them for the first time.... bail out.
      unless firewall.rules['windows'].key?(k) && firewall.rules['windows'][k] == v
        firewall.rules['windows'][k] = v

        new_resource.notifies(:restart, firewall, :delayed)
        new_resource.updated_by_last_action(true)
      end
    end
  end
end
