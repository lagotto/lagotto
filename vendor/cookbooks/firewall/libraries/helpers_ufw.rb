module FirewallCookbook
  module Helpers
    module Ufw
      include FirewallCookbook::Helpers
      include Chef::Mixin::ShellOut

      def ufw_rules_filename
        '/etc/default/ufw-chef.rules'
      end

      def ufw_active?
        cmd = shell_out!('ufw', 'status')
        cmd.stdout =~ /^Status:\sactive/
      end

      def ufw_disable!
        shell_out!('ufw', 'disable', input: 'yes')
      end

      def ufw_enable!
        shell_out!('ufw', 'enable', input: 'yes')
      end

      def ufw_reset!
        shell_out!('ufw', 'reset', input: 'yes')
      end

      def ufw_logging!(param)
        shell_out!('ufw', 'logging', param.to_s)
      end

      def ufw_rule!(cmd)
        shell_out!(cmd, input: 'yes')
      end

      def build_rule(new_resource)
        type = new_resource.command
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
        ufw_command << rule(new_resource).split
        ufw_command.flatten.join(' ')
      end

      def rule(new_resource)
        return new_resource.raw.strip if new_resource.raw

        rule = ''
        rule << "#{new_resource.command.to_s} "
        rule << rule_interface(new_resource)
        rule << rule_logging(new_resource)
        rule << rule_proto(new_resource)
        rule << rule_dest_port(new_resource)
        rule << rule_source_port(new_resource)
        rule.strip
      end

      def rule_interface(new_resource)
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

      def rule_proto(new_resource)
        rule = ''
        rule << "proto #{new_resource.protocol} " if new_resource.protocol && new_resource.protocol.to_s.to_sym != :none
        rule
      end

      def rule_dest_port(new_resource)
        rule = ''
        if new_resource.destination
          rule << "to #{new_resource.destination} "
        else
          rule << 'to any '
        end
        rule << "port #{port_to_s(dport_calc(new_resource))} " if dport_calc(new_resource)
        rule
      end

      def rule_source_port(new_resource)
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

      def rule_logging(new_resource)
        case new_resource.logging && new_resource.logging.to_sym
        when :connections
          'log '
        when :packets
          'log-all '
        else
          ''
        end
      end
    end
  end
end
