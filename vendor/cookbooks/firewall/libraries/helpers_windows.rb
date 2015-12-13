module FirewallCookbook
  module Helpers
    module Windows
      include FirewallCookbook::Helpers
      include Chef::Mixin::ShellOut

      def fixup_cidr(str)
        newstr = str.clone
        newstr.gsub!('0.0.0.0/0', 'any') if newstr.include?('0.0.0.0/0')
        newstr.gsub!('/0', '') if newstr.include?('/0')
        newstr
      end

      def windows_rules_filename
        "#{ENV['HOME']}/windows-chef.rules"
      end

      def active?
        @active ||= begin
          cmd = shell_out!('netsh advfirewall show currentprofile')
          cmd.stdout =~ /^State\sON/
        end
      end

      def enable!
        shell_out!('netsh advfirewall set currentprofile state on')
      end

      def disable!
        shell_out!('netsh advfirewall set currentprofile state off')
      end

      def reset!
        shell_out!('netsh advfirewall reset')
      end

      def add_rule!(params)
        shell_out!("netsh advfirewall #{params}")
      end

      def delete_all_rules!
        shell_out!('netsh advfirewall firewall delete rule name=all')
      end

      def to_type(new_resource)
        cmd = new_resource.command
        if cmd == :reject || cmd == :deny
          type = :block
        else
          type = :allow
        end
        type
      end

      def build_rule(new_resource)
        type = to_type(new_resource)
        parameters = {}

        parameters['description'] = "\"#{new_resource.description}\""
        parameters['dir'] = new_resource.direction

        new_resource.program && parameters['program'] = new_resource.program
        parameters['service'] = new_resource.service ? new_resource.service : 'any'
        parameters['protocol'] = new_resource.protocol

        if new_resource.direction.to_sym == :out
          parameters['localip'] = new_resource.source ? fixup_cidr(new_resource.source) : 'any'
          parameters['localport'] = new_resource.source_port ? port_to_s(new_resource.source_port) : 'any'
          parameters['interfacetype'] = new_resource.source_interface ? new_resource.source_interface : 'any'
          parameters['remoteip'] = new_resource.destination ? fixup_cidr(new_resource.destination) : 'any'
          parameters['remoteport'] = port_to_s(new_resource.dest_port) ? new_resource.dest_port : 'any'
        else
          parameters['localip'] = new_resource.destination ? new_resource.destination : 'any'
          parameters['localport'] = dport_calc(new_resource) ? port_to_s(dport_calc(new_resource)) : 'any'
          parameters['interfacetype'] = new_resource.dest_interface ? new_resource.dest_interface : 'any'
          parameters['remoteip'] = new_resource.source ? fixup_cidr(new_resource.source) : 'any'
          parameters['remoteport'] = new_resource.source_port ? port_to_s(new_resource.source_port) : 'any'
        end

        parameters['action'] = type.to_s

        partial_command = parameters.map { |k, v| "#{k}=#{v}" }.join(' ')
        "firewall add rule name=\"#{new_resource.name}\" #{partial_command}"
      end

      def rule_exists?(name)
        @exists ||= begin
          cmd = shell_out!("netsh advfirewall firewall show rule name=\"#{name}\"", returns: [0, 1])
          cmd.stdout !~ /^No rules match the specified criteria/
        end
      end

      def show_all_rules!
        cmd = shell_out!('netsh advfirewall firewall show rule name=all')
        cmd.stdout.each_line do |line|
          Chef::Log.warn(line)
        end
      end

      def rule_up_to_date?(name, type)
        @up_to_date ||= begin
          desired_parameters = rule_parameters(type)
          current_parameters = {}

          cmd = shell_out!("netsh advfirewall firewall show rule name=\"#{name}\" verbose")
          cmd.stdout.each_line do |line|
            current_parameters['description'] = "\"#{Regexp.last_match(1).chomp}\"" if line =~ /^Description:\s+(.*)$/
            current_parameters['dir'] = Regexp.last_match(1).chomp if line =~ /^Direction:\s+(.*)$/
            current_parameters['program'] = Regexp.last_match(1).chomp if line =~ /^Program:\s+(.*)$/
            current_parameters['service'] = Regexp.last_match(1).chomp if line =~ /^Service:\s+(.*)$/
            current_parameters['protocol'] = Regexp.last_match(1).chomp if line =~ /^Protocol:\s+(.*)$/
            current_parameters['localip'] = Regexp.last_match(1).chomp if line =~ /^LocalIP:\s+(.*)$/
            current_parameters['localport'] = Regexp.last_match(1).chomp if line =~ /^LocalPort:\s+(.*)$/
            current_parameters['interfacetype'] = Regexp.last_match(1).chomp if line =~ /^InterfaceTypes:\s+(.*)$/
            current_parameters['remoteip'] = Regexp.last_match(1).chomp if line =~ /^RemoteIP:\s+(.*)$/
            current_parameters['remoteport'] = Regexp.last_match(1).chomp if line =~ /^RemotePort:\s+(.*)$/
            current_parameters['action'] = Regexp.last_match(1).chomp if line =~ /^Action:\s+(.*)$/
          end

          up_to_date = true
          desired_parameters.each do |k, v|
            up_to_date = false if current_parameters[k] !~ /^["]?#{v}["]?$/i
          end

          up_to_date
        end
      end
    end
  end
end
