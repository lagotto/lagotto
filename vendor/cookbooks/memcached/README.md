memcached Cookbook
==================

[![Build Status](https://travis-ci.org/chef-cookbooks/memcached.svg?branch=master)](http://travis-ci.org/chef-cookbooks/memcached)
[![Cookbook Version](https://img.shields.io/cookbook/v/memcached.svg)](https://supermarket.chef.io/cookbooks/memcached)

Installs/configures a single memcached instance managed by the systems init system.  Also provides a custom resource to set up one or more memcached instances running under runit.


Requirements
------------

#### Platforms
- Debian / Ubuntu
- RHEL and derivatives
- Fedora
- openSUSE/SLES
- SmartOS base64 1.8.1 - Note that SMF directly configures memcached with no opportunity to alter settings. If you need custom parameters, use the `memcached_instance` provider instead.

#### Chef
- Chef 12+

#### Cookbooks
- runit
- yum-epel
- compat_resource


Attributes
----------
The following are node attributes are used to configure `/etc/memcached.conf` if using the default.rb recipe. They are not used if using the memcached_instance custom resource.

- `memcached['memory']` - maximum memory for memcached instances.
- `memcached['user']` - user to run memcached as.
- `memcached['port']` - TCP port for memcached to listen on.
- `memcached['udp_port']` - UDP port for memcached to listen on.
- `memcached['listen']` - IP address for memcache to listen on, defaults to **0.0.0.0** (world accessible).
- `memcached['maxconn']` - maximum number of connections to accept (defaults to 1024)
- `memcached['max_object_size']` - maximum size of an object to cache (defaults to 1MB)
- `memcached['logfilepath']` - path to directory where log file will be written.
- `memcached['logfilename']` - logfile to which memcached output will be redirected in $logfilepath/$logfilename.
- `memcached['threads']` - Number of threads to use to process incoming requests. The default is 4.
- `memcached['experimental_options']` - Comma separated list of extended or experimental options. (array)
- `memcached['ulimit']` - boolean `true` will set the ulimit to the `maxconn` value

Usage
-----
This cookbook can be used to to setup a single memcached instance running under the system's init provider by including `memcached::default` on your runlist.  The above documented attributes can be used to control the configuration of that service.

The cookbook can also within other cookbooks in your infrastructure with the `memcached_instance` custom resource.  See the documentation below for the usage and examples of that custom resource.

##Custom Resources

### instance
Adds or removes an instance of memcached running under the runit supervisor.

#### Actions
- :add: Add a new instance
- :remove: Remove an existing instance

#### Properties
- :memory - the amount of memory allocated for the cache. default: 64
- :port - the TCP port to listen on. default: 11,211
- :udp_port - the UDP port to listen on. default: 11,211
- :listen - the IP to listen on. default: '0.0.0.0'
- :maxconn - the maximum number of connections to accept. default: 1024
- :user - the user to run as
- :threads - the number of threads to use
- :max_object_size - the largest object size to store
- :experimental_options - an array of additional config options
- :ulimit - the ulimit setting to use for the service
- :template_cookbook - the cookbook containing the runit service template. default: memcached

#### Examples

Create a new memached instance named super_custom_memcached:

```ruby
memcached_instance 'super_custom_memcached' do
  port 11_212
  memory 128
end
```
Stop and disable the super_custom_memcached instance:

```ruby
memcached_instance 'super_custom_memcached'  do
  action :remove
end
```

License & Authors
-----------------
- Author:: Cookbook Engineering Team (<cookbooks@chef.io>)
- Author:: Joshua Sierles (<joshua@37signals.com>)

```text
Copyright:: 2009-2015, Chef Software, Inc
Copyright:: 2009, 37signals

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
