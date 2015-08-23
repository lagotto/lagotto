#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: firwall
# Resource:: rule
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
  class Provider::FirewallRuleUfw < Provider
    include Poise
    include Chef::Mixin::ShellOut
    include FirewallCookbook::Helpers

    def action_allow
      if rule_exists?
        Chef::Log.info("#{new_resource.name} already allowed, skipping")
      else
        apply_rule(:allow)
      end
    end

    def action_deny
      if rule_exists?
        Chef::Log.info("#{new_resource.name} already denied, skipping")
      else
        apply_rule(:deny)
      end
    end

    def action_reject
      if rule_exists?
        Chef::Log.info("#{new_resource.name} already rejected, skipping")
      else
        apply_rule(:reject)
      end
    end

    private

    def apply_rule(type = nil)
      Chef::Log.info("#{new_resource.name} apply_rule #{type}")
      # if we don't do this, we may see some bugs where traffic is opened on all ports to all hosts when only RELATED,ESTABLISHED was intended
      if new_resource.stateful
        msg = ''
        msg << "firewall_rule[#{new_resource.name}] was asked to "
        msg << "#{type} a stateful rule using #{new_resource.stateful} "
        msg << 'but ufw does not support this kind of rule. Consider guarding by platform_family.'
        fail msg
      end

      # if we don't do this, ufw will fail as it does not support protocol numbers, so we'll only allow it to run if specifying icmp/tcp/udp protocol types
      if new_resource.protocol && !new_resource.protocol.to_s.downcase.match('^(tcp|udp|icmp)$')
        msg = ''
        msg << "firewall_rule[#{new_resource.name}] was asked to "
        msg << "#{type} a rule using protocol #{new_resource.protocol} "
        msg << 'but ufw does not support this kind of rule. Consider guarding by platform_family.'
        fail msg
      end

      # some examples:
      # ufw allow from 192.168.0.4 to any port 22
      # ufw deny proto tcp from 10.0.0.0/8 to 192.168.0.1 port 25
      # ufw insert 1 allow proto tcp from 0.0.0.0/0 to 192.168.0.1 port 25

      ufw_command = ['ufw']
      if new_resource.position
        ufw_command << 'insert'
        ufw_command << new_resource.position.to_s
      end
      ufw_command << type.to_s
      ufw_command << rule.split

      converge_by("firewall_rule[#{new_resource.name}] #{rule}") do
        notifying_block do
          # fail 'should be no actions'
          shell_out!(*ufw_command.flatten)
          shell_out!('ufw', 'status', 'verbose') # purely for the Chef::Log.debug output
          new_resource.updated_by_last_action(true)
        end
      end
    end

    def rule
      rule = ''
      rule << rule_interface
      rule << rule_logging
      rule << rule_proto
      rule << rule_dest_port
      rule << rule_source_port
      rule.strip
    end

    def rule_interface
      rule = ''
      rule << "#{new_resource.direction} " if new_resource.direction
      if new_resource.interface
        if new_resource.direction
          rule << "on #{new_resource.interface} "
        else
          rule << "in on #{new_resource.interface} "
        end
      end
      rule
    end

    def rule_proto
      rule = ''
      rule << "proto #{new_resource.protocol} " if new_resource.protocol
      rule
    end

    def rule_dest_port
      rule = ''
      if new_resource.destination
        rule << "to #{new_resource.destination} "
      else
        rule << 'to any '
      end
      rule << "port #{port_to_s(dport_calc)} " if dport_calc
      rule
    end

    def rule_source_port
      rule = ''

      if new_resource.source
        rule << "from #{new_resource.source} "
      else
        rule << 'from any '
      end

      if new_resource.source_port
        rule << "port #{port_to_s(new_resource.source_port)} "
      end
      rule
    end

    def rule_logging
      case new_resource.logging && new_resource.logging.to_sym
      when :connections
        'log '
      when :packets
        'log-all '
      else
        ''
      end
    end

    # TODO: currently only works when firewall is enabled
    def rule_exists?
      Chef::Log.info("#{new_resource.name} rule_exists?")
      # To                         Action      From
      # --                         ------      ----
      # 22                         ALLOW       Anywhere
      # 192.168.0.1 25/tcp         DENY        10.0.0.0/8
      # 22                         ALLOW       Anywhere
      # 3309 on eth9               ALLOW       Anywhere
      # Anywhere                   ALLOW       Anywhere
      # 80                         ALLOW       Anywhere (log)
      # 8080                       DENY        192.168.1.0/24
      # 1.2.3.5 5469/udp           ALLOW       1.2.3.4 5469/udp
      # 3308                       ALLOW       OUT Anywhere on eth8

      to = rule_exists_to? # col 1
      action = rule_exists_action? # col 2
      from = rule_exists_from? # col 3

      # full regex from columns
      regex = rule_exists_regex?(to, action, from)

      match = shell_out!('ufw', 'status').stdout.lines.find do |line|
        # TODO: support IPv6
        return false if line =~ /\(v6\)$/
        line =~ regex
      end

      match
    end

    def rule_exists_to?
      to = ''
      to << rule_exists_dest?

      proto = rule_exists_proto?
      to << proto if proto

      if to.empty?
        to << "Anywhere\s"
      else
        to
      end
    end

    def rule_exists_action?
      action = new_resource.action
      action = action.first if action.is_a?(Enumerable)
      "#{Regexp.escape(action.to_s.upcase)}\s"
    end

    def rule_exists_from?
      if new_resource.source && new_resource.source != '0.0.0.0/0'
        Regexp.escape(new_resource.source)
      elsif new_resource.source
        Regexp.escape('Anywhere')
      end
    end

    def rule_exists_dest?
      if new_resource.destination
        "#{Regexp.escape(new_resource.destination)}\s"
      else
        ''
      end
    end

    def rule_exists_regex?(to, action, from)
      if to && new_resource.direction && new_resource.direction.to_sym == :out
        /^#{to}.*#{action}OUT\s.*#{from}$/
      elsif to
        /^#{to}.*#{action}.*#{from}$/
      end
    end

    def rule_exists_proto?
      if new_resource.protocol && dport_calc
        "#{Regexp.escape(port_to_s(dport_calc))}/#{Regexp.escape(new_resource.protocol)}\s "
      elsif dport_calc
        "#{Regexp.escape(port_to_s(dport_calc))}\s "
      end
    end

    def dport_calc
      new_resource.dest_port || new_resource.port
    end
  end
end
