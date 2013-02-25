require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

action :append do
  if new_resource.rule.kind_of?(String)
    rules = [new_resource.rule]
  else
    rules = new_resource.rule
  end

  test_rules(new_resource, rules)

  if not node["simple_iptables"]["chains"].include?(new_resource.chain)
    node.default["simple_iptables"]["chains"] << new_resource.chain
    node.default["simple_iptables"]["rules"] << "-A #{new_resource.direction} --jump #{new_resource.chain}"
  end

  # Then apply the rules to the node
  rules.each do |rule|
    new_rule = rule_string(new_resource, rule)
    if not node["simple_iptables"]["rules"].include?(new_rule)
      node.default["simple_iptables"]["rules"] << new_rule
      new_resource.updated_by_last_action(true)
      Chef::Log.debug("added rule '#{new_rule}'")
    else
      Chef::Log.debug("ignoring duplicate simple_iptables_rule '#{new_rule}'")
    end
  end
end

def test_rules(new_resource, rules)
  shell_out!("iptables --new-chain _chef_lwrp_test")
  begin
    rules.each do |rule|
      new_rule = rule_string(new_resource, rule)
      new_rule.gsub!("-A #{new_resource.chain}", "-A _chef_lwrp_test")
      shell_out!("iptables #{new_rule}")
    end
  ensure
    shell_out("iptables --flush _chef_lwrp_test")
    shell_out("iptables --delete-chain _chef_lwrp_test")
  end
end

def rule_string(new_resource, rule)
  jump = new_resource.jump ? " --jump #{new_resource.jump}" : ""
  rule = "-A #{new_resource.chain} #{rule}#{jump}"
  rule
end
