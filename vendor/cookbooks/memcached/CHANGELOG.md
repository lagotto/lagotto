memcached Cookbook CHANGELOG
============================
This file is used to list changes made in each version of the memcached cookbook.


v1.5.0
------
### Improvement
- **[COOK-3336](https://tickets.opscode.com/browse/COOK-3336)** - Add option to specify logfile
- **[COOK-3299](https://tickets.opscode.com/browse/COOK-3299)** - Document that `memcached` is exposed by default

### Bug
- **[COOK-2990](https://tickets.opscode.com/browse/COOK-2990)** - Include `listen`, `maxconn`, and `user` in the runit service

### New Feature
- **[COOK-2790](https://tickets.opscode.com/browse/COOK-2790)** - Add support for defining max object size

v1.4.0
------
### Improvement
- [COOK-2756]: add SUSE support to memcached cookbook
- [COOK-2791]: Remove the template for Karmic from the memcached cookbook

### Bug
- [COOK-2600]: support memcached on SmartOS

v1.3.0
------
- [COOK-2386] - update `memcached_instance` definition for `runit_service` resource

v1.2.0
------
- [COOK-1469] - include yum epel recipe on RHEL 5 (introduces yum cookbook dependency)
- [COOK-2202] - Fix typo in previous ticket/commits
- [COOK-2266] - pin runit dependency

v1.1.2
------
- [COOK-990] - params insite runit_service isn't the same as outside

v1.1.0
------
- [COOK-1764] - Add Max Connections to memcached.conf and fix typos

v1.0.4
------
- [COOK-1192] - metadata doesn't include RH platforms (supported)
- [COOK-1354] - dev package changed name on centos6

v1.0.2
------
- [COOK-1081] - support for centos/rhel

v1.0.0
------
- [COOK-706] - Additional info in README
- [COOK-828] - Package for RHEL systems

v0.10.4
-------
- Current released version
