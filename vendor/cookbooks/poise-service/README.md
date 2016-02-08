# Poise-Service Cookbook

[![Build Status](https://img.shields.io/travis/poise/poise-service.svg)](https://travis-ci.org/poise/poise-service)
[![Gem Version](https://img.shields.io/gem/v/poise-service.svg)](https://rubygems.org/gems/poise-service)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-service.svg)](https://supermarket.chef.io/cookbooks/poise-service)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-service.svg)](https://codecov.io/github/poise/poise-service)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-service.svg)](https://gemnasium.com/poise/poise-service)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to provide a unified interface for
services.

### What is poise-service?

Poise-service is a tool for developers of "library cookbooks" to define a
service without forcing the end-user of the library to adhere to their choice of
service management framework. The `poise_service` resource represents an
abstract service to be run, which can then be customized by node attributes and
the `poise_service_options` resource. This is a technique called [dependency
injection](https://en.wikipedia.org/wiki/Dependency_injection), and allows a
measure of decoupling between the library and application cookbooks.

### Why would I use poise-service?

Poise-service is most useful for authors of library-style cookbooks, for example
the `apache2`, `mysql`, or `application` cookbooks. When using other service
management options with Chef, the author of the library cookbook has to add
specific code for each service management framework they want to support, often
resulting in a cookbook only supporting the favorite framework of the author or
depending on distribution packages for their init scripts. The `poise_service`
resource allows library cookbook authors a way to write generic code for all
service management frameworks while still allowing users of that cookbook to
choose which service management framework best fits their needs.

### How is this different from the built-in service resource?

Chef includes a `service` resource which allows interacting with certain
service management frameworks such as SysV, Upstart, and systemd.
`poise-service` goes further in that it actually generates the configuration
files needed for the requested service management framework, as well as offering
a dependency injection system for application cookbooks to customize which
framework is used.

### What service management frameworks are supported?

* [SysV (aka /etc/init.d)](#sysvinit)
* [Upstart](#upstart)
* [systemd](#systemd)
* [Inittab](#inittab)
* [Runit](https://github.com/poise/poise-service-runit)
* [Monit](https://github.com/poise/poise-monit#service-provider)
* [Solaris](https://github.com/sh9189/poise-service-solaris)
* [AIX](https://github.com/johnbellone/poise-service-aix)
* *Supervisor (coming soon!)*


## Quick Start

To create a service user and a service to run Apache2:

```ruby
poise_service_user 'www-data'

poise_service 'apache2' do
  command '/usr/sbin/apache2 -f /etc/apache2/apache2.conf -DFOREGROUND'
  stop_signal 'WINCH'
  reload_signal 'USR1'
end
```

or for a hypothetical Rails web application:

```ruby
poise_service_user 'myapp'

poise_service 'myapp-web' do
  command 'bundle exec unicorn -p 8080'
  user 'myapp'
  directory '/srv/myapp'
  environment RAILS_ENV: 'production'
end
```

## Resources

### `poise_service`

The `poise_service` resource is the abstract definition of a service.

```ruby
poise_service 'myapp' do
  command 'myapp --serve'
  environment RAILS_ENV: 'production'
end
```

#### Actions

* `:enable` – Create, enable and start the service. *(default)*
* `:disable` – Stop, disable, and destroy the service.
* `:start` – Start the service.
* `:stop` – Stop the service.
* `:restart` – Stop and then start the service.
* `:reload` – Send the configured reload signal to the service.

#### Attributes

* `service_name` – Name of the service. *(name attribute)*
* `command` – Command to run for the service. This command must stay in the
  foreground and not daemonize itself. *(required)*
* `user` – User to run the service as. See
  [`poise_service_user`](#poise_service_user) for any easy way to create service
   users. *(default: root)*
* `directory` – Working directory for the service. *(default: home directory for
  user, or / if not found)*
* `environment` – Environment variables for the service.
* `stop_signal` – Signal to use to stop the service. Some systems will fall back
  to SIGKILL if this signal fails to stop the process. *(default: TERM)*
* `reload_signal` – Signal to use to reload the service. *(default: HUP)*
* `restart_on_update` – If true, the service will be restarted if the service
  definition or configuration changes. If `'immediately'`, the notification will
  happen in immediate mode. *(default: true)*

#### Service Options

The `poise-service` library offers an additional way to pass configuration
information to the final service called "options". Options are key/value pairs
that are passed down to the service provider and can be used to control how it
creates and manages the service. These can be set in the `poise_service`
resource using the `options` method, in node attributes or via the
`poise_service_options` resource. The options from all sources are merged
together in to a single hash.

When setting options in the resource you can either set them for all providers:

```ruby
poise_service 'myapp' do
  command 'myapp --serve'
  options status_port: 8000
end
```

or for a single provider:

```ruby
poise_service 'myapp' do
  command 'myapp --serve'
  options :systemd, after_target: 'network'
end
```

Setting via node attributes is generally how an end-user or application cookbook
will set options to customize services in the library cookbooks they are using.
You can set options for all services or for a single service, by service name
or by resource name:

```ruby
# Global, for all services.
override['poise-service']['options']['after_target'] = 'network'
# Single service.
override['poise-service']['myapp']['template'] = 'myapp.erb'
```

The `poise_service_options` resource is also available to set node attributes
for a specific service in a DSL-friendly way:

```ruby
poise_service_options 'myapp' do
  template 'myapp.erb'
  restart_on_update false
end
```

Unlike resource attributes, service options can be different for each provider.
Not all providers support the same options so make sure to check the
documentation for each provider to see what options are available.

### `poise_service_options`

The `poise_service_options` resource allows setting per-service options in a
DSL-friendly way. See [the Service Options](#service-options) section for more
information about service options overall.

```ruby
poise_service_options 'myapp' do
  template 'myapp.erb'
  restart_on_update false
end
```

#### Actions

* `:run` – Apply the service options. *(default)*

#### Attributes

* `resource` – Name of the service. *(name attribute)*
* `for_provider` – Provider to set options for.

All other attribute keys will be used as options data.

### `poise_service_user`

The `poise_service_user` resource is an easy way to create service users. It is
not required to use `poise_service`, it is only a helper.

```ruby
poise_service_user 'myapp' do
  home '/srv/myapp'
end
```

#### Actions

* `:create` – Create the user and group. *(default)*
* `:remove` – Remove the user and group.

#### Attributes

* `user` – Name of the user. *(name attribute)*
* `group` – Name of the group. Set to `false` to disable group creation. *(name attribute)*
* `uid` – UID of the user. If unspecified it will be automatically allocated.
* `gid` – GID of the group. If unspecified it will be automatically allocated.
* `home` – Home directory of the user.

## Providers

### `sysvinit`

The `sysvinit` provider supports SystemV-style init systems on Debian-family and
RHEL-family platforms. It will create the `/etc/init.d/<service_name>` script
and enable/disable the service using the platform-specific service resource.

```ruby
poise_service 'myapp' do
  provider :sysvinit
  command 'myapp --serve'
end
```

By default a PID file will be created in `/var/run/service_name.pid`. You can
use the `pid_file` option detailed below to override this and rely on your
process creating a PID file in the given path.

#### Options

* `pid_file` – Path to PID file that the service command will create.
* `template` – Override the default script template. If you want to use a
  template in a different cookbook use `'cookbook:template'`.
* `command` – Override the service command.
* `directory` – Override the service directory.
* `environment` – Override the service environment variables.
* `reload_signal` – Override the service reload signal.
* `stop_signal` – Override the service stop signal.
* `user` – Override the service user.
* `never_restart` – Never try to restart the service.
* `never_reload` – Never try to reload the service.
* `script_path` – Override the path to the generated service script.

### `upstart`

The `upstart` provider supports [Upstart](http://upstart.ubuntu.com/). It will
create the `/etc/init/service_name.conf` configuration.

```ruby
poise_service 'myapp' do
  provider :upstart
  command 'myapp --serve'
end
```

As a wide variety of versions of Upstart are in use in various Linux
distributions, the provider does its best to identify which features are
available and provide shims as appropriate. Most of these should be invisible
however Upstart older than 1.10 does not support setting a `reload signal` so
only SIGHUP can be used. You can set a `reload_shim` option to enable an
internal implementaion of reloading to be used for signals other than SIGHUP,
however as this is implemented inside Chef code, running `initctl reload` would
still result in SIGHUP being sent. For this reason, the feature is disabled by
default and will throw an error if a reload signal other than SIGHUP is used.

#### Options

* `reload_shim` – Enable the reload signal shim. See above for a warning about
  this feature.
* `template` – Override the default configuration template. If you want to use a
  template in a different cookbook use `'cookbook:template'`.
* `command` – Override the service command.
* `directory` – Override the service directory.
* `environment` – Override the service environment variables.
* `reload_signal` – Override the service reload signal.
* `stop_signal` – Override the service stop signal.
* `user` – Override the service user.
* `never_restart` – Never try to restart the service.
* `never_reload` – Never try to reload the service.

### `systemd`

The `systemd` provider supports [systemd](http://www.freedesktop.org/wiki/Software/systemd/).
It will create the `/etc/systemd/system/service_name.service` configuration.


```ruby
poise_service 'myapp' do
  provider :systemd
  command 'myapp --serve'
end
```

#### Options

* `template` – Override the default configuration template. If you want to use a
  template in a different cookbook use `'cookbook:template'`.
* `command` – Override the service command.
* `directory` – Override the service directory.
* `environment` – Override the service environment variables.
* `reload_signal` – Override the service reload signal.
* `stop_signal` – Override the service stop signal.
* `user` – Override the service user.
* `never_restart` – Never try to restart the service.
* `never_reload` – Never try to reload the service.
* `auto_reload` – Run `systemctl daemon-reload` after changes to the unit file. *(default: true)*

### `inittab`

The `inittab` provider supports managing services via `/etc/inittab` using
[SystemV Init](http://www.nongnu.org/sysvinit/). This can provide basic
process supervision even on very old *nix machines.

```ruby
poise_service 'myapp' do
  provider :inittab
  command 'myapp --serve'
end
```

**NOTE:** Inittab does not allow stopping services, and they are started as soon
as they are enabled.

#### Options

* `never_restart` – Never try to restart the service.
* `never_reload` – Never try to reload the service.
* `pid_file` – Path to PID file that the service command will create.
* `service_id` – Unique 1-4 character tag for the service. Defaults to an
  auto-generated hash based on the service name. If these collide, bad things
  happen. Don't do that.

## ServiceMixin

For the common case of a resource (LWRP or plain Ruby) that roughly maps to
"some config files and a service" poise-service provides a mixin module,
`PoiseService::ServiceMixin`. This mixin adds the standard service actions
(`enable`, `disable`, `start`, `stop`, `restart`, and `reload`) with basic
implementations that call those actions on a `poise_service` resource for you.
You customize the service by defining a `service_options` method on your
provider class:

```ruby
def service_options(service)
  # service is the PoiseService::Resource object instance.
  service.command "/usr/sbin/#{new_resource.name} -f /etc/#{new_resource.name}/conf/httpd.conf -DFOREGROUND"
  service.stop_signal 'WINCH'
  service.reload_signal 'USR1'
end
```

You will generally want to override the `enable` action to install things
related to the service like packages, users and configuration files:

```ruby
def action_enable
  notifying_block do
    package 'apache2'
    poise_service_user 'www-data'
    template "/etc/#{new_resource.name}/conf/httpd.conf" do
      # ...
    end
  end
  # This super call will run the normal service enable,
  # creating the service and starting it.
  super
end
```

See [the poise_service_test_mixin resource](test/cookbooks/poise-service_test/resources/mixin.rb)
and [provider](test/cookbooks/poise-service_test/providers/mixin.rb) for
examples of using `ServiceMixin` in an LWRP.

## Sponsors

Development sponsored by [Bloomberg](http://www.bloomberg.com/company/technology/).

The Poise test server infrastructure is sponsored by [Rackspace](https://rackspace.com/).

## License

Copyright 2015-2016, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
