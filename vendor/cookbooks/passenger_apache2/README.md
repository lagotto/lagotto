passenger_apache2 Cookbook
==========================
Installs passenger for Apache 2.


Requirements
------------
Requires Chef 0.10.10+ and Ohai 0.6.10+ for `platform_family` attribute use.

### Platforms
Tested on the following platforms:

- Ubuntu 10.04, 12.04
- CentOS 5.8, 6.3

The source install method was used on CentOS. It may work on other platforms with or without modification.

### Cookbooks
Opscode cookbooks:

- apache2
- build-essential


Attributes
----------
* `node['passenger']['version']` - Specify the version of passenger to install.
* `node['passenger']['max_pool_size']` - Sets PassengerMaxPoolSize in the Apache module config.
* `node['passenger']['root_path']` - The location of the passenger gem.
* `node['passenger']['ruby_bin']` - Sets PassengerRuby in the Apache module config and is used for passenger module configuration. Defaults to `node['languages']['ruby']['ruby_bin']`.
* `node['passenger']['module_path']` - The location of the compiled passenger apache module.
* `node['passenger']['install_method']` - Includes the "source" (gem install) or "package" recipe. Default "source."
* `node['passenger']['apache_mpm']` - Override with an "override_attribute" (in a role, environment or with node.override) to "worker" or "threaded" to use apache2-threaded-dev package. Otherwise this assumes prefork.
* `node['passenger']['package']['name']` - Name of the package for passenger, default is nil, so this must be set before using the "package" install method/recipe.
* `node['passenger']['package']['version']` - Specify the version of the passenger package to install. Uses `version` attribute above by default. To install the version available by default (latest, usually), delete the attribute in a recipe with this line:

  ```ruby
  node.set['passenger']['package'].delete('version')
  ```


Recipes
-------
### default
Installs passenger from gem (source) or package depending on the value of the `install_method` attribute.

### mod_rails
Installs the passenger gem and enables the module in Apache2.

### source
Installs passenger as a RubyGem.

### package
Installs passenger as a Package.

Set the `install_method` attribute to package, then set the `package['name']` attribute to the correct package for your platform. The recipe does not yet handle adding yum repositories for RHEL platforms, so that should be done in another recipe until COOK-2414 is resolved.

Set the `node['passenger']['package']['version']` attribute to the correct value for your system's available package repository if necessary. By default the value is nil which will install the latest package version from the distribution package manager.


Usage
-----
For example, to run a Rails application on passenger:

```ruby
include_recipe "rails"
include_recipe "passenger_apache2"

web_app "myproj" do
  docroot "/srv/myproj/public"
  server_name "myproj.#{node[:domain]}"
  server_aliases [ "myproj", node[:hostname] ]
  rails_env "production"
end
```

A sample config template is provided, `web_app.conf.erb`. If this is suitable for your application, add 'cookbook "passenger"' to the define above to use that template. Otherwise, copy the template to the cookbook where you're using `web_app`, and modify as needed. The cookbook parameter is optional, if omitted it will search the cookbook where the define is used.


License & Authors
-----------------
- Author: Joshua Timberman (<joshua@opscode.com>)
- Author: Joshua Sierles (<joshua@37signals.com>)
- Author: Michael Hale (<mikehale@gmail.com>)
- Author: Chris Roberts (<chrisroberts.code@gmail.com>)

```text
Copyright: 2009-2013, Opscode, Inc
Copyright: 2009, 37signals
Copright: 2009, Michael Hale

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
