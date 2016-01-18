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
  class Provider::FirewallRuleGeneric < Chef::Provider::LWRPBase
    provides :firewall_rule

    action :create do
      return unless new_resource.notify_firewall

      firewall_resource = run_context.resource_collection.find(firewall: new_resource.firewall_name)
      fail 'could not find a firewall resource' unless firewall_resource

      new_resource.notifies(:restart, firewall_resource, :delayed)
      new_resource.updated_by_last_action(true)
    end
  end
end
