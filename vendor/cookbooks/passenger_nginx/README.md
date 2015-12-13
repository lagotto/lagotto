passenger_nginx Cookbook
==========================
Installs passenger with Nginx, using the Phusion PPA.


Requirements
------------
Requires Chef 0.10.10+ and Ohai 0.6.10+ for `platform_family` attribute use.

### Platforms
Tested on the following platforms:

- Ubuntu 12.04, 14.04

### Cookbooks
Opscode cookbooks:

- apt
- build-essential
- nodejs

Other cookbooks:

- [ruby](https://github.com/lagotto/ruby-cookbook)
- [dotenv](https://github.com/lagotto/dotenv-cookbook)
- [capistrano](https://github.com/lagotto/capistrano)

Attributes
----------
* `node['nginx']['user']` - Defaults to `www-data`.
* `node['nginx']['dir']` - Defaults to `/etc/nginx`.
* `node['nginx']['log_dir']` - Defaults to `/var/log/nginx`.
* `node['nginx']['worker_processes']` - Defaults to `4`.
* `node['nginx']['worker_connections']` - Defaults to `768`.
* `node['nginx']['default_site_enabled']` - Defaults to `true`.
* `node['rails']['application']` - Defaults to `app`.
* `node['rails']['rails_env']` - Defaults to `production`.
* `node['rails']['group']` - Defaults to `www-data`.


Recipes
-------
### default
Installs passenger from the [Phusion PPA](http://blog.phusion.nl/2013/09/11/debian-and-ubuntu-packages-for-phusion-passenger/). Usually not used directly, because the recipe is included in the `passenger_nginx` resource.


Resources/Providers
-------

### passenger_nginx

The `passenger_nginx` LWRP configures Nginx with Passenger.

# Attribute Parameters

* `name` - Name of the application. Used to construct the document root at `/var/www/NAME/current/public`
* `rails_env` - Rails enviroment used by Passenger. Defaults to `production`.
* `owner` - Owner for application folder. Defaults to `www-data`.
* `group` - Group for application folder. Defaults to `www-data`.
* `default_server` - Whether the application is the default server when multiple virtual hosts are present. Defaults to `true`.


Usage
-----
For example, to run a Rails application on passenger:

```ruby
passenger_nginx "myproj" do
  rails_env "production"
end
```


License & Authors
-----------------
- Author: Martin Fenner (<mfenner@plos.org>)

```text
Copyright: 2014, Public Library of Science

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
