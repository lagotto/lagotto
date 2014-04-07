CouchDB Cookbook CHANGELOG
==========================
This file is used to list changes made in each version of the CouchDB cookbook.

v2.5.1
------
New cookbook maintainer
Update default version to CouchDB 1.5.0
Update source download URL to new format
Fix testkitchen support
Fix stray "w" in 1.5.0


v2.5.0
------
Porting to use cookbook yum ~> 3.0
Fixing up style to pass rubocop
Updating testing bits


v2.4.8
------
fixing metadata version error. locking to 3.0"


v2.4.6
------
Locking yum dependency to '< 3'


v2.4.4
------
### Bug
- **[COOK-3659](https://tickets.opscode.com/browse/COOK-3659)** - Don't change directory ownership of `/var/run`

v2.4.2
------
### Bug
- **[COOK-3323](https://tickets.opscode.com/browse/COOK-3323)** - Force `local.ini` file changes to restart CouchDB

v2.4.0
------
- [COOK-1629] - source recipe not working on centos 5.8
- [COOK-2608] - Update source install version to 1.2.1

v2.2.0
------
- [COOK-1905] - It should be possible to customize the local.ini file in couchdb cookbook

v2.1.0
------
- [COOK-2139] - fedora has couchdb package, no EPEL required

v2.0.0
------
Major version bump due to use of platform_family (only available on newer versions of ohai/chef).

- [COOK-1838] - Switch to platform_family approach to support scientific

v1.0.4
------
- [COOK-1623] - add attribute to prevent erlang installation
- [COOK-1627] - set attributes at default precedence instead of normal (set)

v1.0.2
------
- [COOK-1399] - make bind address an attribute

v1.0.0
------
- Create group for couchdb
