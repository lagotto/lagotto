## v2.0.0:

[COOK-2115] - Improve `passenger_apache2` cookbook source
[COOK-2128] - Allow apache passenger to be installed via packages
[COOK-2203] - Remove :source key from `module_path`
[COOK-2379] - `passenger_apache2` should install passenger 3.0.19
[COOK-2380] - `pasenger_apache2` should use `platform_family` for additional platform support

## v1.1.0:

* [COOK-2003] - only able to use apache2-prefork-dev to compile
  passenger

## v1.0.0:

* [COOK-1097] - documentation missing for mod_rails recipe
* [COOK-1132] - example doesn't work
* [COOK-1133] - update to passenger v3.0.11

## v0.99.4:

* [COOK-958] - fix regression for loadmodule on debian/ubuntu
* [COOK-1003] - support archlinux

## v0.99.2:

* [COOK-859] - don't hardcode module path
* [COOK-539] - use --auto for installation
* [COOK-608] - remove RailsAllowModRewrite from web_app.erb
* [COOK-640] - use correct development headers on RHEL

## v0.99.0:

* Upgrade to passenger 3.0.7
* Attributes are all "default"
* Install curl development headers
* Move PassengerMaxPoolSize to config of module instead of vhost.
