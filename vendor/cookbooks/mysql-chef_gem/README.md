Cross Platform Cookbook
=======================

Making custom Chef resource cross platform.

Scope
-----
This cookbook is concerned with cross platform things.
This cookbook does not do everything.

Requirements
------------
* Chef 11 or higher
* Ruby 1.9 (preferably from the Chef full-stack installer)

Resources / Providers
---------------------
### crossplat_thing

The `crossplat_thing` resource configures things.

### Example

    crossplat_thing 'default' do
      action :create
    end

Recipes
-------
### crossplat::default

This recipe calls a `crossplat_thing` resource, passing parameters
from node attributes.

Usage
-----
The `crossplat::server` recipe and `crossplat_thing` resources are
designed to do things.

### run_list

Include `'recipe[crossplat::default]'`

### Wrapper cookbook

    node.default['crossplat']['an_attribute'] = 'Chef'

    include_recipe 'crossplat::default'

    ruby_block 'wat' do
      notifies :restart, crossplat_thing[wat]'
    end

### Used directly in a recipe

    crossplat_thing 'wat' do
      action :create
    end

    ruby_block 'wat' do
      notifies :restart, crossplat_thing[wat]'
    end

Attributes
----------

    default['crossplat']['resource_name'] = 'default'
    default['crossplat']['an_attribute'] = 'chef'

License & Authors
-----------------
- Author:: Sean OMeara (<someara@opscode.com>)

```text
Copyright:: 2009-2014 Chef Software, Inc

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
