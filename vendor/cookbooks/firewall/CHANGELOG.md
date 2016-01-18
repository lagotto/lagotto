firewall Cookbook CHANGELOG
=======================
This file is used to list changes made in each version of the firewall cookbook.

v2.3.1 (2016-01-08)
-------------------
* Add raw rule support to the ufw firewall provider (#113).

v2.3.0 (2015-12-23)
-------------------
* Refactor logic so that firewall rules don't add a string rule to the firewall
when their actions run. Just run the action once on the firewall itself. This is
designed to prevent partial application of rules (#106)

* Switch to "enabled" (positive logic) instead of "disabled" (negative logic) on
the firewall resource. It was difficult to reason with "disabled false" for some
complicated recipes using firewall downstream. `disabled` is now deprecated.

* Add proper Windows testing and serverspec tests back into this cookbook.

* Fix the `port_to_s` function so it also works for Windows (#111)

* Fix typo checking action instead of command in iptables helper (#112)

* Remove testing ranges of ports on CentOS 5.x, as it's broken there.

v2.2.0 (2015-11-02)
-------------------
Added permanent as default option for RHEL 7 based systems using firewall-cmd.
This defaults to turned off, but it will be enabled by default on the next major version bump.

v2.1.0 (2015-10-15)
-------------------
Minor feature release.
* Ensure ICMPv6 is open when `['firewall']['allow_established']` is set to true (the default). ICMPv6 is critical for most IPv6 operations.

v2.0.5 (2015-10-05)
-------------------
Minor bugfix release.
* Ensure provider filtering always yields 1 and only 1 provider, #97 & #98
* Documentation update #96

v2.0.4 (2015-09-23)
-------------------
Minor bugfix release.
* Allow override of filter chain policies, #94
* Fix foodcrtitic and chefspec errors

v2.0.3 (2015-09-14)
-------------------
Minor bugfix release.
* Fix wrong conditional for firewalld ports, #93
* Fix ipv6 command logic under iptables, #91

v2.0.2 (2015-09-08)
-------------------
* Release with working CI, Chefspec matchers.

v2.0.1 (2015-09-01)
-------------------
* Add default related/established rule for iptables

v2.0.0 (2015-08-31)
-------------------
* #84, major rewrite:
  - Allow relative positioning of rules
  - Use delayed notifications to create one firewall ruleset instead of incremental changes
  - Remove poise dependency
* #82 - Introduce Windows firewall support and test-kitchen platform.
* #73 - Add the option to disable ipv6 commands on iptables
* #78 - Use Chef-12 style `provides` to address provider mapping issues
* Rubocop and foodcritic cleanup

v1.6.1 (2015-07-24)
-------------------
* #80 - Remove an extra space in port range

v1.6.0 (2015-07-15)
-------------------
* #68 - Install firewalld when it does not exist
* #72 - Fix symbol that was a string, breaking comparisons

v1.5.2 (2015-07-15)
-------------------
* #75 - Use correct service in iptables save action, Add serverspec tests for iptables suite

v1.5.1 (2015-07-13)
-------------------
* #74 - add :save matcher for Chefspec

v1.5.0 (2015-07-06)
-------------------

* #70 - Add chef service resource to ensure firewall-related services are enabled/disabled
*     - Add testing and support for iptables on ubuntu in iptables provider

v1.4.0 (2015-06-30)
-------------------

* #69 - Support for CentOS/RHEL 5.x

v1.3.0 (2015-06-09)
-------------------
* #63 - Add support for protocol numbers

v1.2.0 (2015-05-28)
-------------------
* #64 - Support the newer version of poise

v1.1.2 (2015-05-19)
-------------------
* #60 - Always add /32 or /128 to ipv4 or ipv6 addresses, respectively.
      - Make comment quoting optional; iptables on Ubuntu strips quotes on strings without any spaces

v1.1.1 (2015-05-11)
-------------------
* #57 - Suppress warning: already initialized constant XXX while Chefspec

v1.1.0 (2015-04-27)
-------------------
* #56 - Better ipv6 support for firewalld and iptables
* #54 - Document raw parameter

v1.0.2 (2015-04-03)
-------------------
* #52 - Typo in :masquerade action name

v1.0.1 (2015-03-28)
-------------------
* #49 - Fix position attribute of firewall_rule providers to be correctly used as a string in commands

v1.0.0 (2015-03-25)
-------------------
* Major upgrade and rewrite as HWRP using poise
* Adds support for iptables and firewalld
* Modernize tests and other files
* Fix many bugs from ufw defaults to multiport suppot

v0.11.8 (2014-05-20)
--------------------
* Corrects issue where on a secondary converge would not distinguish between inbound and outbound rules


v0.11.6 (2014-02-28)
--------------------
[COOK-4385] - UFW provider is broken


v0.11.4 (2014-02-25)
--------------------
[COOK-4140] Only notify when a rule is actually added


v0.11.2
-------
### Bug
- **[COOK-3615](https://tickets.opscode.com/browse/COOK-3615)** - Install required UFW package on Debian

v0.11.0
-------
### Improvement
- [COOK-2932]: ufw providers work on debian but cannot be used

v0.10.2
-------
- [COOK-2250] - improve readme

v0.10.0
------
- [COOK-1234] - allow multiple ports per rule

v0.9.2
------
- [COOK-1615] - Firewall example docs have incorrect direction syntax

v0.9.0
------
The default action for firewall LWRP is now :enable, the default action for firewall_rule LWRP is now :reject. This is in line with a "default deny" policy.

- [COOK-1429] - resolve foodcritic warnings

v0.8.0
------
- refactor all resources and providers into LWRPs
- removed :reset action from firewall resource (couldn't find a good way to make it idempotent)
- removed :logging action from firewall resource...just set desired level via the log_level attribute

v0.6.0
------
- [COOK-725] Firewall cookbook firewall_rule LWRP needs to support logging attribute.
- Firewall cookbook firewall LWRP needs to support :logging

v0.5.7
------
- [COOK-696] Firewall cookbook firewall_rule LWRP needs to support interface
- [COOK-697] Firewall cookbook firewall_rule LWRP needs to support the direction for the rules

v0.5.6
------
- [COOK-695] Firewall cookbook firewall_rule LWRP needs to support destination port

v0.5.5
------
- [COOK-709] fixed :nothing action for the 'firewall_rule' resource.

v0.5.4
------
- [COOK-694] added :reject action to the 'firewall_rule' resource.

v0.5.3
------
- [COOK-698] added :reset action to the 'firewall' resource.

v0.5.2
------
- Add missing 'requires' statements. fixes 'NameError: uninitialized constant' error.
thanks to Ernad Husremović for the fix.

v0.5.0
------
- [COOK-686] create firewall and firewall_rule resources
- [COOK-687] create UFW providers for all resources
