Description
===========

Installs and configures CouchDB. Optionally can install CouchDB from sources.

Requirements
============

Requires a platform that can install Erlang from distribution packages.

## Platform

Originally tested on Debian 5+, Ubuntu 8.10+, OpenBSD and FreeBSD.

Also works on Red Hat, CentOS and Fedora, requires the EPEL yum repository.

Tested via Test Kitchen (1.0-alpha):

* Ubuntu 10.04, 12.04
* CentOS 5.8, 6.3

## Cookbooks

* erlang

When using the `couchdb::source` recipe, the `build-essential` recipe
is required. It is not a direct dependency of this cookbook as it is
an optional installation method, and package installation is
recommended.

Attributes
==========

Cookbook attributes are named under the `couch_db` keyspace.

* `node['couch_db']['src_checksum']` - sha256sum of the default version of couchdb to download
* `node['couch_db']['src_version']` - default version of couchdb to download, used in the full URL to download.
* `node['couch_db']['src_mirror']` - full URL to download.
* `node['couch_db']['install_erlang']` - specify if erlang should be installed prior to
  couchdb, true by default.

Configuration
-------------

The `local.ini` file is dynamically generated from attributes. Each key in
`node['couch_db']['config']` is a CouchDB configuration directive, and will
be rendered in the config file. For example, the attribute:

    node['couch_db']['config']['httpd']['bind_address'] = "0.0.0.0"

Will result in the following lines in the `local.ini` file:

    [httpd]
    bind_address = "0.0.0.0"

The attributes file contains default values for platform-independent
parameters. All parameter values that expect a path argument are
not set by default. The default values that are currently set have
been taken from the CouchDB configuration
[wiki page](http://wiki.apache.org/couchdb/Configurationfile_couch.ini).

The resulting configuration file is now dynamically rendered from the
attributes. Each subkey below the `config` key is a specific section
of the `local.ini` file. Then each subkey in a section is a parameter
associated with a value.

You should consult the CouchDB documentation for specific
configuration details.

For values that are "on" or "off", they should be specified as literal
`true` or `false`. Any configuration option set to the literal `nil` will
be skipped entirely. All other values (e.g., string, numeric literals) will
be used as is. So for example:

    node.default['couch_db']['config']['couchdb']['os_process_timeout'] = 5000
    node.default['couch_db']['config']['couchdb']['delayed_commits'] = true
    node.default['couch_db']['config']['couchdb']['batch_save_interval'] = nil
    node.default['couch_db']['config']['httpd']['port'] = 5984
    node.default['couch_db']['config']['httpd']['bind_address'] = "127.0.0.1"

Will result in the following config lines:

    [couchdb]
    os_process_timeout = 5000
    delayed_commits = true

    [httpd]
    port = 5984
    bind_address = 127.0.0.1

(no line printed for `batch_save_interval` as it is `nil`)

### Defaults

Here the list of attributes that are already provided by the recipe
and their associated default value.

#### Section [couchdb]

* `node['couch_db']['config]['couchdb']['max_document_size']` -
   Maximum size of a document in bytes, defaults to `4294967296` (`4 GB`).
* `node['couch_db']['config]['couchdb']['max_attachment_chunk_size']` -
   Maximum chunk size of an attachment in bytes, defaults to `4294967296` (`4 GB`).
* `node['couch_db']['config]['couchdb']['os_process_timeout']` -
   OS process timeout for view and external servers in milliseconds, defaults to `5000` (`5 seconds`).
* `node['couch_db']['config]['couchdb']['max_dbs_open']` -
   Upper bound limit on the number of databases that can be open at one time, defaults to `100`.
* `node['couch_db']['config]['couchdb']['delayed_commits']` -
   Determines if commits should be delayed, defaults to `true`.
* `node['couch_db']['config]['couchdb']['batch_save_size']` -
   Number of document at which to save a batch, defaults to `1000`.
* `node['couch_db']['config]['couchdb']['batch_save_interval']` -
   Interval after which to save batches in milliseconds, default to `1000` (`1 second`).

#### Section [httpd]

* `node['couch_db']['config']['httpd']['port']` -
   Port CouchDB should bind to, defaults to `5984`.
* `node['couch_db']['config']['httpd']['bind_address']` -
   IP address CouchDB should bind to, defaults to `127.0.0.1`.

#### Section [log]

* `node['couch_db']['config']['log']['level']` -
   CouchDB's log level, defaults to `info`.

Recipes
=======

default
-------

Installs the couchdb package, creates the data directory and starts the couchdb service.

source
------

Downloads the CouchDB source from the Apache project site, plus development dependencies. Then builds the binaries for installation, creates a user and directories, then sets up the couchdb service. Uses the init script provided in the cookbook.

License and Author
==================

* Author: Joshua Timberman (<joshua@opscode.com>)
* Author: Matthieu Vachon (<matthieu.o.vachon@gmail.com>)
* Author: Joan Touzet (<wohali@apache.org>)

Copyright 2009-2014, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
