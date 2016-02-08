default['firewall']['iptables']['defaults'][:policy] = {
  input: 'DROP',
  forward: 'DROP',
  output: 'ACCEPT'
}
default['firewall']['iptables']['defaults'][:ruleset] = {
  '*filter' => 1,
  ":INPUT #{node['firewall']['iptables']['defaults'][:policy][:input]}" => 2,
  ":FORWARD #{node['firewall']['iptables']['defaults'][:policy][:forward]}" => 3,
  ":OUTPUT #{node['firewall']['iptables']['defaults'][:policy][:output]}" => 4,
  'COMMIT_FILTER' => 100
}

default['firewall']['ubuntu_iptables'] = false
default['firewall']['redhat7_iptables'] = false
default['firewall']['allow_established'] = true
default['firewall']['ipv6_enabled'] = true
