# memcached Cookbook CHANGELOG
This file is used to list changes made in each version of the memcached cookbook.

## 2.0.3 (2015-02-16)
- Fix template whitespace location that resulted in bad command

## 2.0.2 (2015-11-20)
- Push new version to Supermarket to deal with bad artifact

## 2.0.1 (2015-11-19)
- Push new version to Supermarket to deal with bad artifact

## 2.0.0 (2015-11-10)
BREAKING CHANGES:
- The user and group attributes have been removed and are instead handled by a helper that picks the appropriate user / group based on the platform
- The memcached_instance definition that used both passed values and node attributes for configuration has been rewritten as a 12.5 custom resource with compat_resource providing backwards compatibility to all Chef 12.X releases.  This new custom resource handles the installation of memcached and all configuration is passed in via custom resource properties.  See the readme for examples of how to use this new resource.  This change should greatly improve the ability to use memcached_instance within wrapper cookbooks.

## 1.9.0 (2015-11-05)
NOTE: This will be the last version of this cookbook that supports Chef 11 and the traditional attribute / resource hybrid setup for memcached instances. After this release this cookbook will function with attributes for a simple install or Chef 12.5 custom resources for creating individual memcached instances.  If you utilize memcached instances using the attributes to define the config you'll need to pin to ~1.0 and later update to the new format in ~2.0.
- Debian/Ubuntu switched the user that memcached runs under from nobody to memcache.  Updated the cookbook to use this user on those platforms and create it in case we're on an older distro release that didn't yet have that user
- Removed use of shellout that was causing issues for users
- Improved the workaround on Debian/Ubuntu for not starting the service on package install so that it doesn't show up as a changed resource on every Chef run
- Updated Chefspec to 4.X and added additional specs
- Add oracle to the metadata
- Add issues_url and source_url to the metadata
- Add new contributing.md, maintainers.md, and testing.md docs
- Add travis and cookbook version badges to the readme
- Clarified Chef 11 is the minimum required chef release
- Updated platforms in the Kitchen config
- Added chefignore file
- Removed all hash rockets
- Added a .foodcritic file with exclusions
- Updated travis to use their container infrastructure, chef-dk for testing deps, and kitchen-docker for integration testing
- Added a Rakefile to simplify testing
- Removed yum as a dependency as it wasn't being used.
- Removed attributes from the metadata as they hadn't been updated

## v1.8.0 (2015-08-11)
- updated serverspec tests to pass (See 3c7b5c9)
- deconflict memcached_instance runit definition from default init (See b06d2d)
  - split `default.rb` into `install.rb` and `configure.rb` so that memcached_instance only starts the specified number of instances

- added attributes `logfilepath`, `version`, `threads`, `experimental_options`, and `ulimit`
- NOTE: if memcached_instance name is not specified or set to "memcached", the instance name will be "memcached". If anything else is specified, the instance name will be "memcached-${name}"

## v1.7.2 (2014-03-12)
- [COOK-4308] - Enable memcache on RHEL, Fedora, and Suse
- [COOK-4212] - Support max_object_size rhel and fedora

## v1.7.0
Updating for yum ~> 3.0. Fixing up style issues for rubocop. Updating test-kitchen harness

## v1.6.6
fixing metadata version error. locking to 3.0

## v1.6.4
Locking yum dependency to '< 3'

## v1.6.2
[COOK-3741] UDP settings for memcached

## v1.6.0
### Bug
- **[COOK-3682](https://tickets.chef.io/browse/COOK-3682)** - Set user when using Debian packages

### Improvement
- **[COOK-3336](https://tickets.chef.io/browse/COOK-3336)** - Add an option to specify the logfile (fix)

## v1.5.0
### Improvement
- **[COOK-3336](https://tickets.chef.io/browse/COOK-3336)** - Add option to specify logfile
- **[COOK-3299](https://tickets.chef.io/browse/COOK-3299)** - Document that `memcached` is exposed by default

### Bug
- **[COOK-2990](https://tickets.chef.io/browse/COOK-2990)** - Include `listen`, `maxconn`, and `user` in the runit service

### New Feature
- **[COOK-2790](https://tickets.chef.io/browse/COOK-2790)** - Add support for defining max object size

## v1.4.0
### Improvement
- [COOK-2756]: add SUSE support to memcached cookbook
- [COOK-2791]: Remove the template for Karmic from the memcached cookbook

### Bug
- [COOK-2600]: support memcached on SmartOS

## v1.3.0
- [COOK-2386] - update `memcached_instance` definition for `runit_service` resource

## v1.2.0
- [COOK-1469] - include yum epel recipe on RHEL 5 (introduces yum cookbook dependency)
- [COOK-2202] - Fix typo in previous ticket/commits
- [COOK-2266] - pin runit dependency

## v1.1.2
- [COOK-990] - params insite runit_service isn't the same as outside

## v1.1.0
- [COOK-1764] - Add Max Connections to memcached.conf and fix typos

## v1.0.4
- [COOK-1192] - metadata doesn't include RH platforms (supported)
- [COOK-1354] - dev package changed name on centos6

## v1.0.2
- [COOK-1081] - support for centos/rhel

## v1.0.0
- [COOK-706] - Additional info in README
- [COOK-828] - Package for RHEL systems

## v0.10.4
- Current released version
