default['firewall']['iptables']['defaults'] = {
  policy: {
    input: 'DROP',
    forward: 'DROP',
    output: 'ACCEPT'
  }
}

default['firewall']['ubuntu_iptables'] = false
default['firewall']['redhat7_iptables'] = false
default['firewall']['allow_established'] = true
default['firewall']['ipv6_enabled'] = true
