module FirewallCookbook
  module Helpers
    module Firewalld
      include FirewallCookbook::Helpers
      include Chef::Mixin::ShellOut

      def firewalld_rules_filename
        '/etc/sysconfig/firewalld-chef.rules'
      end

      def firewalld_rule!(cmd)
        shell_out!(cmd, input: 'yes')
      end

      def firewalld_active?
        cmd = shell_out('firewall-cmd', '--state')
        cmd.stdout =~ /^running$/
      end

      def firewalld_default_zone?(z)
        cmd = shell_out('firewall-cmd', '--get-default-zone')
        cmd.stdout =~ /^#{z.to_s}$/
      end

      def firewalld_default_zone!(z)
        shell_out!('firewall-cmd', "--set-default-zone=#{z}")
      end

      def log_current_firewalld
        shell_out!('firewall-cmd --direct --get-all-rules')
      end

      def firewalld_flush!
        shell_out!('firewall-cmd', '--direct', '--remove-rules', 'ipv4', 'filter', 'INPUT')
        shell_out!('firewall-cmd', '--direct', '--remove-rules', 'ipv4', 'filter', 'OUTPUT')
        shell_out!('firewall-cmd', '--direct', '--permanent', '--remove-rules', 'ipv4', 'filter', 'INPUT')
        shell_out!('firewall-cmd', '--direct', '--permanent', '--remove-rules', 'ipv4', 'filter', 'OUTPUT')
      end

      def firewalld_all_rules_permanent!
        rules = shell_out!('firewall-cmd', '--direct', '--get-all-rules').stdout
        perm_rules = shell_out!('firewall-cmd', '--direct', '--permanent', '--get-all-rules').stdout
        rules == perm_rules
      end

      def firewalld_save!
        shell_out!('firewall-cmd', '--direct', '--permanent', '--remove-rules', 'ipv4', 'filter', 'INPUT')
        shell_out!('firewall-cmd', '--direct', '--permanent', '--remove-rules', 'ipv4', 'filter', 'OUTPUT')
        shell_out!('firewall-cmd', '--direct', '--get-all-rules').stdout.lines do |line|
          shell_out!("firewall-cmd --direct --permanent --add-rule #{line}")
        end
      end

      def ip_versions(resource)
        if ipv4_rule?(resource)
          versions = ['ipv4']
        elsif ipv6_rule?(resource)
          versions = ['ipv6']
        else # no source or destination address, add rules for both ipv4 and ipv6
          versions = %w(ipv4 ipv6)
        end
        versions
      end

      CHAIN = { in: 'INPUT', out: 'OUTPUT', pre: 'PREROUTING', post: 'POSTROUTING' } unless defined? CHAIN # , nil => "FORWARD"}
      TARGET = { allow: 'ACCEPT', reject: 'REJECT', deny: 'DROP', masquerade: 'MASQUERADE', redirect: 'REDIRECT', log: 'LOG --log-prefix \'iptables: \' --log-level 7' } unless defined? TARGET

      def build_firewall_rule(new_resource, ip_version = 'ipv4')
        type = new_resource.command
        if new_resource.raw
          firewall_rule = new_resource.raw.strip
        else
          firewall_rule = "#{ip_version} filter "
          if new_resource.direction
            firewall_rule << "#{CHAIN[new_resource.direction.to_sym]} "
          else
            firewall_rule << 'FORWARD '
          end
          firewall_rule << "#{new_resource.position} "

          if [:pre, :post].include?(new_resource.direction)
            firewall_rule << '-t nat '
          end

          # Firewalld order of prameters is important here see example output below:
          # ipv4 filter INPUT 1 -s 1.2.3.4/32 -d 5.6.7.8/32 -i lo -p tcp -m tcp -m state --state NEW -m comment --comment "hello" -j DROP
          firewall_rule << "-s #{ip_with_mask(new_resource, new_resource.source)} " if new_resource.source && new_resource.source != '0.0.0.0/0'
          firewall_rule << "-d #{new_resource.destination} " if new_resource.destination

          firewall_rule << "-i #{new_resource.interface} " if new_resource.interface
          firewall_rule << "-o #{new_resource.dest_interface} " if new_resource.dest_interface

          firewall_rule << "-p #{new_resource.protocol} " if new_resource.protocol && new_resource.protocol.to_s.to_sym != :none
          firewall_rule << '-m tcp ' if new_resource.protocol && new_resource.protocol.to_s.to_sym == :tcp

          # using multiport here allows us to simplify our greps and rule building
          firewall_rule << "-m multiport --sports #{port_to_s(new_resource.source_port)} " if new_resource.source_port
          firewall_rule << "-m multiport --dports #{port_to_s(dport_calc(new_resource))} " if dport_calc(new_resource)

          firewall_rule << "-m state --state #{new_resource.stateful.is_a?(Array) ? new_resource.stateful.join(',').upcase : new_resource.stateful.to_s.upcase} " if new_resource.stateful
          firewall_rule << "-m comment --comment '#{new_resource.description}' "
          firewall_rule << "-j #{TARGET[type]} "
          firewall_rule << "--to-ports #{new_resource.redirect_port} " if type == :redirect
          firewall_rule.strip!
        end
        firewall_rule
      end
    end
  end
end
