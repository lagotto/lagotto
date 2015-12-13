default['firewall']['ufw']['defaults'] = {
  ipv6: 'yes',
  manage_builtins: 'no',
  ipt_sysctl: '/etc/ufw/sysctl.conf',
  ipt_modules: 'nf_conntrack_ftp nf_nat_ftp nf_conntrack_netbios_ns',
  policy: {
    input: 'DROP',
    output: 'ACCEPT',
    forward: 'DROP',
    application: 'SKIP'
  }
}
