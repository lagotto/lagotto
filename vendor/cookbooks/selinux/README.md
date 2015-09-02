Description
===========

Provides recipes for manipulating SELinux policy enforcement state.

Requirements
============

RHEL family distribution or other Linux system that uses SELinux.

## Platform:

Tested on RHEL 5.8, 6.3

Node Attributes
===============

* `node['selinux']['state']` - The SELinux policy enforcement state.
  The state to set  by default, to match the default SELinux state on
  RHEL. Can be "enforcing", "permissive", "disabled"

* `node['selinux']['booleans']` - A hash of SELinux boolean names and the
  values they should be set to. Values can be off, false, or 0 to disable;
  or on, true, or 1 to enable.

Resources/Providers
===================

## selinux\_state

The `selinux_state` LWRP is used to manage the SELinux state on the
system. It does this by using the `setenforce` command and rendering
the `/etc/selinux/config` file from a template.

### Actions

* `:nothing` - default action, does nothing
* `:enforcing` - Sets SELinux to enforcing.
* `:disabled` - Sets SELinux to disabled.
* `:permissive` - Sets SELinux to permissive.

### Attributes

The LWRP has no user-settable resource attributes.

### Examples

Simply set SELinux to enforcing or permissive:

    selinux_state "SELinux Enforcing" do
      action :enforcing
    end

    selinux_state "SELinux Permissive" do
      action :permissive
    end

The action here is based on the value of the
`node['selinux']['state']` attribute, which we convert to lower-case
and make a symbol to pass to the action.

    selinux_state "SELinux #{node['selinux']['state'].capitalize}" do
      action node['selinux']['state'].downcase.to_sym
    end

Recipes
=======

All the recipes now leverage the LWRP described above.

## default

The default recipe will use the attribute `node['selinux']['state']`
in the `selinux_state` LWRP's action. By default, this will be `:enforcing`.

## enforcing

This recipe will use `:enforcing` as the `selinux_state` action.

## permissive

This recipe will use `:permissive` as the `selinux_state` action.

## disabled

This recipe will use `:disabled` as the `selinux_state` action.

Usage
=====

By default, this cookbook will have SELinux enforcing by default, as
the default recipe uses the `node['selinux']['state']` attribute,
which is "enforcing." This is in line with the policy of enforcing by
default on RHEL family distributions.

This has complicated considerations when changing the default
configuration of their systems, whether it is with automated
configuration management or manually. Often, third party help forums
and support sites recommend setting SELinux to "permissive." This
cookbook can help with that, in two ways.

You can simply set the attribute in a role applied to the node:

    name "base"
    description "Base role applied to all nodes."
    default_attributes(
      "selinux" => {
        "state" => "permissive"
      }
    )

Or, you can apply the recipe to the run list (e.g., in a role):

    name "base"
    description "Base role applied to all nodes."
    run_list(
      "recipe[selinux::permissive]",
    )

Roadmap
=======

Add LWRP/Libraries for manipulating security contexts for files and
services managed by Chef.

License and Author
==================

- Author:: Sean OMeara (<someara@chef.io>)
- Author:: Joshua Timberman (<joshua@chef.io>)

Copyright:: 2011-2012, Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
