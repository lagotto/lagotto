# provider mappings for Chef 11
# https://www.chef.io/blog/2015/02/10/chef-12-provider-resolver/

#########
# firewall
#########
Chef::Platform.set platform: :centos, version: '< 7.0', resource: :firewall, provider: Chef::Provider::FirewallIptables
Chef::Platform.set platform: :centos, version: '>= 7.0', resource: :firewall, provider: Chef::Provider::FirewallFirewalld
Chef::Platform.set platform: :redhat, version: '< 7.0', resource: :firewall, provider: Chef::Provider::FirewallIptables
Chef::Platform.set platform: :redhat, version: '>= 7.0', resource: :firewall, provider: Chef::Provider::FirewallFirewalld
Chef::Platform.set platform: :debian, resource: :firewall, provider: Chef::Provider::FirewallUfw
Chef::Platform.set platform: :ubuntu, resource: :firewall, provider: Chef::Provider::FirewallUfw

#########
# firewall_rule
#########
Chef::Platform.set platform: :centos, version: '< 7.0', resource: :firewall_rule, provider: Chef::Provider::FirewallRuleIptables
Chef::Platform.set platform: :centos, version: '>= 7.0', resource: :firewall_rule, provider: Chef::Provider::FirewallRuleFirewalld
Chef::Platform.set platform: :redhat, version: '< 7.0', resource: :firewall_rule, provider: Chef::Provider::FirewallRuleIptables
Chef::Platform.set platform: :redhat, version: '>= 7.0', resource: :firewall_rule, provider: Chef::Provider::FirewallRuleFirewalld
Chef::Platform.set platform: :debian, resource: :firewall_rule, provider: Chef::Provider::FirewallRuleUfw
Chef::Platform.set platform: :ubuntu, resource: :firewall_rule, provider: Chef::Provider::FirewallRuleUfw
