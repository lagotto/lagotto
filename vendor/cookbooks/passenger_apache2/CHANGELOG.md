passenger_apache2 Cookbook CHANGELOG
====================================
This file is used to list changes made in each version of the passenger_apache2 cookbook.

v2.2.0 (2014-02-21)
-------------------
### Bug
- **[COOK-4081](https://tickets.opscode.com/browse/COOK-4081)** - Install command does not use correct attribute

### Improvement
- **[COOK-4005](https://tickets.opscode.com/browse/COOK-4005)** - Make the passenger apache module installation step use optional custom ruby when building from source


v2.1.4
------
### Improvement
- [COOK-4005] Make the passenger apache module installation use optional custom ruby when building from source


v2.1.2
------
### Bug
- [COOK-3706] Fix permission of passenger.load
- [COOK-3747] Call full path for installing module


v2.1.0
------
### Bug
- **[COOK-3654](https://tickets.opscode.com/browse/COOK-3654)** - Fix compatibility with Chef 11
- **[COOK-3395](https://tickets.opscode.com/browse/COOK-3395)** - Fix an issue where the recipe does not compile the version of passenger specified on the node attribute

### Improvement
- **[COOK-3486](https://tickets.opscode.com/browse/COOK-3486)** - Make `PassengerRuby` configurable


v2.0.4
------
### Bug
- **[COOK-2293](https://tickets.opscode.com/browse/COOK-2293)** - Automatically reload Ohai attribtues

v2.0.2
------
### Bug
- [COOK-2750]: using `mod_rails` in `run_list` by itself fails in version 2.0.0
- [COOK-2972]: `passenger_apache2` has foodcritic errors
- [COOK-3180]: don't use `mod_rails` recipe w/ package install

v2.0.0
------
[COOK-2115] - Improve `passenger_apache2` cookbook source
[COOK-2128] - Allow apache passenger to be installed via packages
[COOK-2203] - Remove :source key from `module_path`
[COOK-2379] - `passenger_apache2` should install passenger 3.0.19
[COOK-2380] - `pasenger_apache2` should use `platform_family` for additional platform support

v1.1.0
------
- [COOK-2003] - only able to use apache2-prefork-dev to compile passenger

v1.0.0
------
- [COOK-1097] - documentation missing for mod_rails recipe
- [COOK-1132] - example doesn't work
- [COOK-1133] - update to passenger v3.0.11

v0.99.4
------
- [COOK-958] - fix regression for loadmodule on debian/ubuntu
- [COOK-1003] - support archlinux

v0.99.2
------
- [COOK-859] - don't hardcode module path
- [COOK-539] - use --auto for installation
- [COOK-608] - remove RailsAllowModRewrite from web_app.erb
- [COOK-640] - use correct development headers on RHEL

v0.99.0
------
- Upgrade to passenger 3.0.7
- Attributes are all "default"
- Install curl development headers
- Move PassengerMaxPoolSize to config of module instead of vhost.
