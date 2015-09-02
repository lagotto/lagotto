Mysql_Rails Cookbook
====================

Chef cookbook to configure MySQL for Rails.


Requirements
------------
Requires Chef 0.10.10+ and Ohai 0.6.10+ for `platform_family` attribute use.

### Platforms
Tested on the following platforms:

- Ubuntu 12.04, 14.04

### Cookbooks
Opscode cookbooks:

- mysql
- database


Resources/Providers
-------

### mysql_rails

The `msql_rails` LWRP installs and configures MySQL for Rails.

# Attribute Parameters

* `name` - Name of the application. Used together with `rails_env` for the name of the MySQL database.
* `rails_env` - Rails enviroment, defaults to `production`.
* `user` - MySQL user. Defaults to `root`.
* `password` - MySQL password for `db_user`. Defaults to an empty string.
* `host` - MySQL host. Defaults to `localhost`.


Usage
-----
For example, to run install MySQL, create a database named `myproj_production`, and a user named `boss`, run:

```ruby
mysql_rails "myproj" do
  username    "boss"
  password    "youguessit"
  host        "localhost"
  rails_env   "production"
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
