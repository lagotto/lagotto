module FirewallCookbook
  module Helpers
    def dport_calc(new_resource)
      new_resource.dest_port || new_resource.port
    end

    def port_to_s(p)
      if p && p.is_a?(Integer)
        p.to_s
      elsif p && p.is_a?(Array)
        p.sort.join(',')
      elsif p && p.is_a?(Range)
        "#{p.first}:#{p.last}"
      end
    end

    def ipv6_enabled?(new_resource)
      new_resource.ipv6_enabled
    end

    def disabled?(new_resource)
      Chef::Log.warn("#{new_resource} has attribute 'disabled' = true, not proceeding") if new_resource.disabled
      new_resource.disabled
    end

    def ip_with_mask(new_resource, ip)
      if ip.include?('/')
        ip
      elsif ipv4_rule?(new_resource)
        "#{ip}/32"
      elsif ipv6_rule?(new_resource)
        "#{ip}/128"
      else
        ip
      end
    end

    # ipv4-specific rule?
    def ipv4_rule?(new_resource)
      if (new_resource.source && IPAddr.new(new_resource.source).ipv4?) ||
         (new_resource.destination && IPAddr.new(new_resource.destination).ipv4?)
        true
      else
        false
      end
    end

    # ipv6-specific rule?
    def ipv6_rule?(new_resource)
      if (new_resource.source && IPAddr.new(new_resource.source).ipv6?) ||
         (new_resource.destination && IPAddr.new(new_resource.destination).ipv6?) ||
         new_resource.protocol =~ /ipv6/ ||
         new_resource.protocol =~ /icmpv6/
        true
      else
        false
      end
    end

    def ubuntu?(current_node)
      current_node['platform'] == 'ubuntu'
    end

    def build_rule_file(rules)
      contents = []
      sorted_values = rules.values.sort.uniq
      sorted_values.each do |sorted_value|
        contents << "# position #{sorted_value}"
        rules.each do |k, v|
          next unless v == sorted_value
          contents << k
        end
      end
      "#{contents.join("\n")}\n"
    end
  end
end
