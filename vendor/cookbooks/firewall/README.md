firewall Cookbook
=================

[![Build Status](https://travis-ci.org/chef-cookbooks/firewall.svg?branch=master)](http://travis-ci.org/chef-cookbooks/firewall)
[![Cookbook Version](https://img.shields.io/cookbook/v/firewall.svg)](https://supermarket.chef.io/cookbooks/firewall)

Provides a set of primitives for managing firewalls and associated rules.

PLEASE NOTE - The resource/providers in this cookbook are under heavy development. An attempt is being made to keep the resource simple/stupid by starting with less sophisticated firewall implementations first and refactor/vet the resource definition with each successive provider.

Requirements
------------
**Chef 12.4.x+** is required. We are currently testing against 12.5.1. If you need Chef 11 support, please try pinning back to a version less than 2.0, e.g.:
```
depends 'firewall', '< 2.0'
```

### Supported firewalls and platforms
* UFW - Ubuntu, Debian
* IPTables - Red Hat & CentOS, Ubuntu
* FirewallD - Red Hat & CentOS >= 7.0 (IPv4 only support, [needs contributions/testing](https://github.com/chef-cookbooks/firewall/issues/86))
* Windows Advanced Firewall - 2012 R2

Tested on:
* Ubuntu 12.04 & 14.04 with iptables, ufw
* Debian 7.8, 8.1 with ufw
* CentOS 5.11, 6.7 with iptables
* CentOS 7.1 with firewalld
* Windows Server 2012r2 with Windows Advanced Firewall

By default, Ubuntu chooses ufw. To switch to iptables, set this in an attribute file:
```
default['firewall']['ubuntu_iptables'] = true
```

By default, Red Hat & CentOS >= 7.0 chooses firewalld. To switch to iptables, set this in an attribute file:
```
default['firewall']['redhat7_iptables'] = true
```

# Considerations that apply to all firewall providers and resources

This cookbook comes with two resources, firewall and firewall rule. The typical usage scenario is as follows:

- run the `:install` action on the `firewall` resource named 'default', which installs appropriate packages and configures services to start on boot and starts them

- run the `:create` action on every `firewall_rule` resource, which adds to the list of rules that should be configured on the firewall. `firewall_rule` then automatically sends a delayed notification to the `firewall['default']` resource to run the `:restart` action.

- run the delayed notification with action `:restart` on the `firewall` resource. if any rules are different than the last run, the provider will update the current state of the firewall rules to match the expected rules.

There is a fundamental mismatch between the idea of a chef action and the action that should be taken on a firewall rule. For this reason, the chef action for a firewall_rule may be `:nothing` (the rule should not be present in the firewall) or `:create` (the rule should be present in the firewall), but the action taken on a packet in a firewall (`DROP`, `ACCEPT`, etc) is denoted as a `command` parameter on the `firewall_rule` resource.

# iptables considerations

If you need to use a table other than `*filter`, the best way to do so is like so:
```
node.default['firewall']['iptables']['defaults'][:ruleset] = {
  '*filter' => 1,
  ':INPUT DROP' => 2,
  ':FORWARD DROP' => 3,
  ':OUTPUT ACCEPT' => 4,
  'COMMIT_FILTER' => 100,
  '*nat' => 101,
  ':PREROUTING DROP' => 102,
  ':POSTROUTING DROP' => 103,
  ':OUTPUT ACCEPT' => 104,
  'COMMIT_NAT' => 200
}
```

Then it's trivial to add additional rules to the `*nat` table using the raw parameter:
```
firewall_rule "postroute" do
  raw "-A POSTROUTING -o eth1 -p tcp -d 172.28.128.21 -j SNAT --to-source 172.28.128.6"
  position 150
end
```

Note that any line starting with `COMMIT` will become just `COMMIT`, as hash
keys must be unique but we need multiple commit lines.

# Recipes

### default
The default recipe creates a firewall resource with action install, and if `node['firewall']['allow_ssh']`, opens port 22 from the world.

# Attributes

* `default['firewall']['allow_ssh'] = false`, set true to open port 22 for SSH when the default recipe runs
* `default['firewall']['allow_mosh'] = false`, set to true to open UDP ports 60000 - 61000 for [Mosh][0] when the default recipe runs
* `default['firewall']['allow_winrm'] = false`, set true to open port 5989 for WinRM when the default recipe runs

* `default['firewall']['ubuntu_iptables'] = false`, set to true to use iptables on Ubuntu / Debian when using the default recipe
* `default['firewall']['redhat7_iptables'] = false`, set to true to use iptables on Red Hat / CentOS 7 when using the default recipe

* `default['firewall']['ufw']['defaults']` hash for template `/etc/default/ufw`
* `default['firewall']['iptables']['defaults']` hash for default policies for 'filter' table's chains`

* `default['firewall']['allow_established'] = true`, set to false if you don't want a related/established default rule on iptables
* `default['firewall']['ipv6_enabled'] = true`, set to false if you don't want IPv6 related/established default rule on iptables (this enables ICMPv6, which is required for much of IPv6 communication)

* `default['firewall']['firewalld']['permanent'] = false`, set to true if you want firewalld rules to be added with `--permanent` so they survive a reboot. This will be changed to `true` by default in a future major version release.

# Resources

### firewall

***NB***: The name 'default' of this resource is important as it is used for firewall_rule providers to locate the firewall resource. If you change it, you must also supply the same value to any firewall_rule resources using the `firewall_name` parameter.

#### Actions
- `:install` (*default action*): Install and Enable the firewall. This will ensure the appropriate packages are installed and that any services have been started.
- `:disable`: Disable the firewall. Drop any rules and put the node in an unprotected state. Flush all current rules. Also erase any internal state used to detect when rules should be applied.
- `:flush`: Flush all current rules. Also erase any internal state used to detect when rules should be applied.
- `:save`: Ensure all rules are added permanently under firewalld using `--permanent`. Not supported on ufw, iptables. You must notify this action at the end of the chef run if you want permanent firewalld rules (they are not persistent by default).

#### Parameters

- `disabled` (default to `false`): If set to true, all actions will no-op on this resource. This is a way to prevent included cookbooks from configuring a firewall.
- `ipv6_enabled` (default to `true`): If set to false, firewall will not perform any ipv6 related work. Currently only supported in iptables.
- `log_level`: UFW only. Level of verbosity the firewall should log at. valid values are: :low, :medium, :high, :full. default is :low.
- `rules`: This is used internally for firewall_rule resources to append their rules. You should NOT touch this value unless you plan to supply an entire firewall ruleset at once, and skip using firewall_rule resources.
- `disabled_zone` (firewalld only): The zone to set on firewalld when the firewall should be disabled. Can be any string in symbol form, e.g. :public, :drop, etc. Defaults to `:public.`
- `enabled_zone` (firewalld only): The zone to set on firewalld when the firewall should be enabled. Can be any string in symbol form, e.g. :public, :drop, etc. Defaults to `:drop.`

#### Examples

```ruby
# all defaults
firewall 'default'

# enable platform default firewall
firewall 'default' do
  action :install
end

# increase logging past default of 'low'
firewall 'default' do
  log_level :high
  action    :install
end
```

### firewall_rule

#### Actions
- `:create` (_default action_): If a firewall_rule runs this action, the rule will be recorded in a chef resource's internal state, and applied when providers automatically notify the firewall resource with action `:reload`. The notification happens automatically.

#### Parameters

- `firewall_name`: the matching firewall resource that this rule applies to. Default value: `default`

- `raw`: Used to pass an entire rule as a string, omitting all other parameters. This line will be directly loaded by `iptables-restore`, fed directly into `ufw` on the command line, or run using `firewall-cmd`.

- `description` (_default: same as rule name_): Used to provide a comment that will be included when adding the firewall rule.

- `position` (_default: 50_): **relative** position to insert rule at. Position may be any integer between 0 < n < 100 (exclusive), and more than one rule may specify the same position.

- `command`: What action to take on a particular packet

  - `:allow` (_default action_): the rule should allow matching packets
  - `:deny`: the rule should deny matching packets
  - `:reject`: the rule should reject matching packets
  - `:masqerade`: Masquerade the matching packets
  - `:redirect`: Redirect the matching packets
  - `:log`: Configure logging

- `stateful`: a symbol or array of symbols, such as ``[:related, :established]` that will be passed to the state module in iptables or firewalld.

- `protocol`: `:tcp` (_default_), `:udp`, `:icmp`, `:none` or protocol number. Using protocol numbers is not supported using the ufw provider (default for debian/ubuntu systems).

- `direction`: For ufw, direction of the rule. valid values are: `:in` (_default_), `:out`, `:pre`, `:post`.

- `source` (_Default is `0.0.0.0/0` or `Anywhere`_): source ip address or subnet to filter.

- `source_port` (_Default is nil_): source port for filtering packets.

- `destination`: ip address or subnet to filter on packet destination, must be a valid IP

- `port` or `dest_port`: target port number (ie. 22 to allow inbound SSH), or an array of incoming port numbers (ie. [80,443] to allow inbound HTTP & HTTPS).

   NOTE: `protocol` attribute is required with multiple ports, or a range of incoming port numbers (ie. 60000..61000 to allow inbound mobile-shell. NOTE: `protocol`, or an attribute is required with a range of ports.

- `interface`: (source) interface to apply rule (ie. `eth0`).

- `dest_interface`: interface where packets may be destined to go

- `redirect_port`: redirected port for rules with command `:redirect`

- `logging`: may be added to enable logging for a particular rule. valid values are: `:connections`, `:packets`. In the ufw provider, `:connections` logs new connections while `:packets` logs all packets.

#### Examples

```ruby
# open standard ssh port
firewall_rule 'ssh' do
  port     22
  command  :allow
end

# open standard http port to tcp traffic only; insert as first rule
firewall_rule 'http' do
  port     80
  protocol :tcp
  position 1
  command   :allow
end

# restrict port 13579 to 10.0.111.0/24 on eth0
firewall_rule 'myapplication' do
  port      13579
  source    '10.0.111.0/24'
  direction :in
  interface 'eth0'
  command    :allow
end

# specify a protocol number (supported on centos/redhat)
firewall_rule 'vrrp' do
  protocol    112
  command      :allow
end

# use the iptables provider to specify protocol number on debian/ubuntu
firewall_rule 'vrrp' do
  provider    Chef::Provider::FirewallRuleIptables
  protocol    112
  command      :allow
end

# can use :raw command with UFW provider for VRRP
firewall_rule "VRRP" do
  command   :allow
  raw "allow to 224.0.0.18"
end

# open UDP ports 60000..61000 for mobile shell (mosh.mit.edu), note
# that the protocol attribute is required when using port_range
firewall_rule 'mosh' do
  protocol   :udp
  port       60000..61000
  command     :allow
end

# open multiple ports for http/https, note that the protocol
# attribute is required when using ports
firewall_rule 'http/https' do
  protocol :tcp
  port     [80, 443]
  command   :allow
end

firewall 'default' do
  enabled false
  action :nothing
end
```

#### Providers

- See `libraries/z_provider_mapping.rb` for a full list of providers for each platform and version.

Different providers will determine the current state of the rules differently -- parsing the output of a command, maintaining the state in a file, or some other way. If the firewall is adjusted from outside of chef (non-idempotent), it's possible that chef may be caught unaware of the current state of the firewall. The best workaround is to add a `:flush` action to the firewall resource as early as possible in the chef run, if you plan to modify the firewall state outside of chef.

# Troubleshooting

To figure out what the position values are for current rules, print the hash that contains the weights:
```
require pp
default_firewall = resources(:firewall, 'default')
pp default_firewall.rules
```

# Development
This section details "quick development" steps. For a detailed explanation, see [[Contributing.md]].

1. Clone this repository from GitHub:

        $ git clone git@github.com:chef-cookbooks/firewall.git

2. Create a git branch

        $ git checkout -b my_bug_fix

3. Install dependencies:

        $ bundle install

4. Make your changes/patches/fixes, committing appropiately
5. **Write tests**
6. Run the tests:
    - `bundle exec foodcritic -f any .`
    - `bundle exec rspec`
    - `bundle exec rubocop`
    - `bundle exec kitchen test`

  In detail:
    - Foodcritic will catch any Chef-specific style errors
    - RSpec will run the unit tests
    - Rubocop will check for Ruby-specific style errors
    - Test Kitchen will run and converge the recipes


# License & Authors
<!-- $ find -type f -iname "*.rb" -exec grep -i author '{}' \; | sort -k4 | uniq | sed 's/#/-/g' -->
- Author:: Seth Chisamore (<schisamo@opscode.com>)
- Author:: Ronald Doorn (<rdoorn@schubergphilis.com>)
- Author:: Martin Smith (<martin@mbs3.org>)
- Author:: Sander van Harmelen (<svanharmelen@schubergphilis.com>)

```text
Copyright:: 2011-2015, Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[0]: https://mosh.mit.edu/
