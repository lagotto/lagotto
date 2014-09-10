---
layout: page
title: "Installation"
---

## Introduction

Setting up the ALM application consists of three steps:

* Installation (this document)
* [Deployment](/docs/deployment.md) if you are using ALM in a production system
* [Setup](/docs/setup.md)

ALM is a typical Ruby on Rails web application with one unusual feature: it requires the CouchDB database. CouchDB is used to store the responses from external API calls, MySQL (or PostgreSQL, see below) is used for everything else. The application is used in production systems with Apache/Passenger, Nginx/Passenger and Nginx/Puma. ALM uses Ruby on Rails 3.2.x, migration to Rails 4.x is planned for 2014. The application has extensive test coverage using [Rspec] and [Cucumber].

[Rspec]: http://rspec.info/
[Cucumber]: http://cukes.info/

The ALM application is available as Open Source software using a [Apache license](http://www.apache.org/licenses/LICENSE-2.0.html), all dependencies (software and libraries) are also Open Source.

Because of the background workers that talk to external APIs we recommend at least 1 Gb of RAM, and more if you have a large number of articles. As a rule of thumb you need one worker per 5,000 - 20,000 articles, and 1 Gb of RAM per 10 workers - the exact numbers depend on how often you plan to update articles, e.g. you need more workers if you plan on update your usage stats every day.

#### Ruby
ALM requires Ruby 1.9.3 or greater, and has been tested with Ruby 1.9.3, 2.0 and 2.1. Not all Linux distributions include Ruby 1.9 as a standard install. [RVM] and [Rbenv] are Ruby version management tools for installing Ruby, unfortunately they also introduce additional dependencies, making them not the best choices in a production environment. The Chef script below installs Ruby 2.1.

[RVM]: http://rvm.io/
[Rbenv]: https://github.com/sstephenson/rbenv

#### Installation Options

* automated installation via Vagrant/Chef (recommended)
* manual installation

Hosting the ALM application at a Platform as a Service (PaaS) provider such as Heroku or OpenShift is possible, but has not been tested.

## Automated Installation
This is the recommended way to install the ALM application. The required applications and libraries will automatically be installed in a self-contained virtual machine running Ubuntu 14.04, using [Vagrant] and [Chef Solo].

Start by downloading and installing [Vagrant], and then install the [Omnibus] Vagrant plugin (which installs the newest version of Chef Solo):

```sh
vagrant plugin install vagrant-omnibus
```

The following providers have been tested with the ALM application:

* Virtualbox
* VMware Fusion or Workstation
* Amazon AWS
* Digital Ocean
* Rackspace

Virtualbox and VMware are for local installations, e.g. on a developer machine, whereas the other options are for cloud installations. With the exception of Virtualbox you need to install the appropriate [Vagrant plugin](https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Plugins) with these providers, e.g. for AWS:

```sh
vagrant plugin install vagrant-aws
```

The VMware plugin requires a commercial license, all other plugins are freely available as Open Source software.

### Custom settings (passwords, API keys)
This is an optional step. Rename the file `config.json.example` to `config.json` and add your custom settings to it, including usernames, passwords, API keys and the MySQL password. This will automatically configure the application with your settings.

Some custom settings for the virtual machine are stored in the `Vagrantfile`, and that includes your cloud provider access keys, the ID base virtual machine with Ubuntu 14.04 from by your cloud provider, RAM for the virtual machine, and networking settings for a local installation. A sample configuration for AWS would look like:

```ruby
config.vm.provider :aws do |aws, override|
  aws.access_key_id = "EXAMPLE"
  aws.secret_access_key = "EXAMPLE"
  aws.keypair_name = "EXAMPLE"
  aws.security_groups = ["EXAMPLE"]
  aws.instance_type = "m3.medium"
  aws.ami = "ami-0307d674"
  aws.region = "eu-west-1"
  aws.tags = { Name: 'Vagrant ALM' }
  override.vm.hostname = "ALM.EXAMPLE.ORG"
  override.ssh.username = "ubuntu"
  override.ssh.private_key_path = "~/path/to/ec2/key.pem"
  override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

  # Custom parameters for the ALM recipe
  chef_overrides['alm'] = {
    'user' => 'ubuntu',
    'group' => 'ubuntu',
    'provider' => 'aws'
  }

  provision(config, override, chef_overrides)
end
```

For Digital Ocean the configuration could look like this:

```ruby
config.vm.provider :digital_ocean do |provider, override|
  override.ssh.private_key_path = '~/YOUR_PRIVATE_SSH_KEY'
  override.vm.box = 'digital_ocean'
  override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  override.ssh.username = "ubuntu"

  provider.region = 'nyc2'
  provider.image = 'Ubuntu 14.04 x64'
  provider.size = '1GB'

  # please configure
  override.vm.hostname = "ALM.EXAMPLE.ORG"
  provider.token = 'EXAMPLE'

  provision(config, override, chef_overrides)
end
```

The sample configurations for AWS and Digital Ocean is included in the `Vagrantfile`.

### Cookbooks

The [Chef cookbooks](https://supermarket.getchef.com/) needed by the ALM cookbook are managed by [librarian-chef](https://github.com/applicationsonline/librarian-chef), which is installed as a Ruby gem:

```
gem install librarian-chef
```

The required cookbooks are listed in the `Cheffile`, and are automatically installed into `vendor/cookbooks`.

### Installation

Then install all the required software for the ALM application with:

```sh
git clone git://github.com/articlemetrics/alm.git
cd alm
vagrant up
```

[Virtualbox]: https://www.virtualbox.org/wiki/Downloads
[Vagrant]: http://downloads.vagrantup.com/
[Omnibus]: https://github.com/schisamo/vagrant-omnibus
[Chef Solo]: http://docs.opscode.com/chef_solo.html

This can take up to 15 min, future updates with `vagrant provision` are of course much faster. To get into in the virtual machine, use ssh and then switch to the directory of the application:

```sh
vagrant ssh
cd /var/www/alm/current
```

This uses the private SSH key provided by you in the `Vagrantfile` (the default insecure key for local installations using Virtualbox is `~/.vagrant.d/insecure_private_key`). The `vagrant` user has sudo privileges. The MySQL password is stored at `config/database.yml`, and is auto-generated during the installation. CouchDB is set up to run in **Admin Party** mode, i.e. without usernames or passwords. The database servers can be reached from the virtual machine or via port forwarding. Vagrant syncs the folder on the host containing the checked out ALM git repo with the folder `/var/www/alm/current` on the guest.

## Manual installation
These instructions assume a fresh installation of Ubuntu 14.04 and a user with sudo privileges. Installation on other Unix/Linux platforms should be similar, but may require additional steps to install a recent Ruby (at least 1.9.3 is required).

#### Add PPAs to install more recent versions of Ruby and CouchDB, and Nginx/Passeger
We only need one Ruby version and manage gems with bundler, so there is no need to install `rvm` or `rbenv`. We want to install the latest CouchDB version from the official PPA, and we want to install Nginx precompiled with Passenger.

```sh
sudo apt-get install python-software-properties
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo add-apt-repository ppa:couchdb/stable

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo apt-get install apt-transport-https ca-certificates
deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list
```

#### Update package lists

```sh
sudo apt-get update
```

#### Install Ruby and required packages
Also install the `curl` and `git` packages, the `libmysqlclient-dev` library required by the `myslq2` gem, the `libpq-dev` library required by the `pg`gem, and `nodejs` as Javascript runtime. When running ALM on a local machine we also want to install `avahi-daemon` and `libnss-mdns`for zeroconf networking.

```sh
sudo apt-get install ruby2.1 ruby2.1-dev curl git libmysqlclient-dev nodejs avahi-daemon libnss-mdns
```

#### Install databases

```sh
sudo apt-get install couchdb mysql-server
```

#### Install Memcached
Memcached is used to cache requests (in particular API requests), and the default configuration can be used. If you want to run memcached on a different host, change `config.cache_store = :dalli_store, { :namespace => "alm" }` in `config/environments/production.rb` to `config.cache_store = :dalli_store, 'cache.example.com', { :namespace => "alm" }`.

```sh
sudo apt-get install memcached
```

#### Install Postfix
Postfix is used to send reports via email. Alternatively, a different SMTP host can be configured in `config/settings.yml`.

```sh
sudo apt-get install postfix
```

The default configuration assumes `address: localhost`, `port: 25`. You can configure mail in `config/settings.yml`:

```yaml
mail:
  address:
  port:
  domain:
  user_name:
  password:
  authentication:
```

More information can be found [here](http://guides.rubyonrails.org/action_mailer_basics.html).

#### Install Nginx with Passenger

```sh
sudo apt-get install nginx-full passenger
```

Edit `/etc/nginx/nginx.conf` and uncomment `passenger_root` and `passenger_ruby`.

#### Set up Nginx virtual host
Please set `ServerName` if you have set up more than one virtual host. Also don't forget to add`AllowEncodedSlashes On` to the Apache virtual host file in order to keep Apache from messing up encoded embedded slashes in DOIs. Use `passenger_app_env development` to use the Rails development environment.

```
server {
  listen 80 default_server;
  server_name EXAMPLE.ORG;
  root /var/www/alm/current/public;
  access_log /var/log/nginx/alm.access.log;
  passenger_enabled on;
  passenger_app_env production;
}
```

#### Install ALM code
You may have to set the permissions first, depending on your server setup. Passenger by default is run by the user who owns `config.ru`.

```sh
dd /var/www
git clone git://github.com/articlemetrics/alm.git
```

#### Install Bundler and Ruby gems required by the application
Bundler is a tool to manage dependencies of Ruby applications: http://gembundler.com.

```sh
sudo gem install bundler

cd /var/www/alm
bundle install
```

#### Set ALM configuration settings
You want to set the MySQL username/password in `database.yml`, using either the root password that you generated when you installed MySQL, or a different MySQL user. You also want to set the site and session keys in `settings.yml`, they can be generated with `rake secret`.

```sh
cd /var/www/alm
cp config/database.yml.example config/database.yml
cp config/settings.yml.example config/settings.yml
```

#### Install ALM databases
We just setup an empty database for CouchDB. With MySQL we also include all data to get started, including sample articles and a default user account (username/password _articlemetrics_). Use `RAILS_ENV=production` if you set up Passenger to run in the production environment.

It is possible to connect the ALM app to MySQL and/or CouchDB running on a different server, please change `host` in database.yml and `couched_url` in settings.yml accordingly.

```sh
cd /var/www/alm
rake db:setup RAILS_ENV=production
curl -X PUT http://localhost:5984/alm/
```

#### Restart Nginx
We are making `alm` the default site.

```sh
sudo service nginx restart
```

You can now access the ALM application with your web browser at the name or IP address of your Ubuntu installation.

## Using PostgreSQL instead of MySQL
The instructions above are for using MySQL, but the ALM application can also be installed with PostgreSQL by changing the database adapter in `config/database.yml` to use PostgreSQL instead of MySQL (change the line in defaults to `<<:postgres`):

```yaml
mysql: &mysql
  adapter: mysql2
  username: root
  password: YOUR_PASSWORD

postgresql: &postgres
  adapter: postgresql
  username: postgres
  password: YOUR_PASSWORD
  pool: 10
  min_messages: ERROR

defaults: &defaults
  pool: 5
  timeout: 5000
  database: alm_<%= Rails.env %>
  host: localhost

  <<: *<%= ENV['DB'] || "mysql" %>

development:
  <<: *defaults

test:
  <<: *defaults

production:
  <<: *defaults
```

## Running ALM on multiple servers

The ALM software was developed to run on a single server, but most components scale to multiple servers. When running ALM on multiple servers, make sure that:

* the name used in the load balancer is set as `public_server` in `config/settings.yml`
* memcached should be set up as a cluster by adding a `web_servers` list with all ALM servers behind the load balancer to `config/settings.yml`, e.g. `web_servers: [example1.org, example2.org]`
* workers should run on only one server (work is in progress to scale to multiple servers), e.g. the server with the capistrano `:db` role
* database maintenance rake tasks should run on only one server, capistrano defaults to install the cron jobs only for the `:db` role.
* mail services (sending emails) should run on only one server. They are part of the database maintenance tasks, so by default run only on the server with the `:db` role.
