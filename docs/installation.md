---
layout: card_list
title: "Installation"
---

## Introduction

Configuring Lagotto consists of three steps:

* Installation (this document)
* [Deployment](/docs/deployment) if you are using Lagotto in a production system
* [Setup](/docs/setup)

Lagotto is a typical Ruby on Rails web application, using MySQL (or PostgreSQL, see below), Memcached, Redis, Nginx, and Passenger. Lagotto uses Ruby version 2.2 or higher, and Ruby on Rails 4.x. The application has extensive test coverage using [Rspec].

[Rspec]: http://rspec.info/

Lagotto is Open Source software licensed with a [MIT License](https://github.com/lagotto/lagotto/blob/master/LICENSE.md), all dependencies (software and libraries) are also Open Source. Because of the background workers that talk to external APIs we recommend at least 1 Gb of RAM, and more if you have a large number of works.

#### Ruby
Lagotto requires Ruby 2.2 or higher. [RVM] and [Rbenv] are Ruby version management tools for installing Ruby, unfortunately they also introduce additional dependencies, making them not the best choices in a production environment. The Chef script below installs Ruby 2.2 using a PPA for Ubuntu, this PPA is also recommended for manual installations on Ubuntu.

[RVM]: http://rvm.io/
[Rbenv]: https://github.com/sstephenson/rbenv

#### Installation Options

* automated installation via Vagrant/Chef (recommended)
* manual installation

Hosting Lagotto at a Platform as a Service (PaaS) provider such as Heroku or OpenShift is possible, but has not been tested.

## Configuration options

Starting with the Lagotto 3.7 release all user-specific configuration options for Rails, as well as for the server configuration and deployment tools Vagrant, Chef and Capistrano are environment variables, and are stored in a single `.env` file. Copy `.env.example` example configuration file provided with the application to get started.

More information regarding ENV variables and `.env` is available [here](https://github.com/bkeepers/dotenv). The following configuration options need to be set:

```sh
# Example configuration settings for this application

APPLICATION=lagotto
RAILS_ENV=development

# custom settings, e.g header and footer
MODE=default

# Human friendly name of the organization running this software. For use
# in report generation to attribute ownership of the produced reports.
CREATOR=Public Library of Science

# database settings
DB_NAME=lagotto
DB_USERNAME=vagrant
DB_PASSWORD=
DB_HOST=127.0.0.1
DB_SLAVE_HOST=127.0.0.1
DB_PORT=3306
DB_POOL=100

# mysql server root password for chef
DB_ROOT_PASSWORD=EZ$zspyxF2

# redis server
REDIS_URL=redis://127.0.0.1:6379/4

# internal name of server
HOSTNAME=lagotto.local

# public name of server
# can be HOSTNAME, or different if load balancer is used
SERVERNAME=lagotto.local
SERVER_URL=http://127.0.0.1

# all instances of server used behind load balancer
# can be HOSTNAME, or comma-delimited string of HOSTNAME
SERVERS=lagotto.local

# memcached servers
# can be HOSTNAME, or comma-delimited string of HOSTNAME
# MEMCACHE_SERVERS=

# consul server cluster, defaults to HOSTNAME if left empty
# CONSUL_SERVERS=

# name used on navigation bar and in email subject line
SITE_NAME=ALM Dev

# Longer, more descriptive name of the installation site
SITE_TITLE="PLOS ALM"

# email address for sending emails
ADMIN_EMAIL=info@example.org

# number of threads Sidekiq uses
CONCURRENCY=25

# keys
# run `rake secret` to generate these keys
API_KEY=8897f9349100728d66d64d56bc21254bb346a9ed21954933
SECRET_KEY_BASE=c436de247c988eb5d0908407e700098fc3992040629bb8f98223cd221e94ee4d15626aae5d815f153f3dbbce2724ccb8569c4e26a0f6f663375f6f2697f1f3cf

# token for Github metadata lookup
GITHUB_PERSONAL_ACCESS_TOKEN=

# uncomment to always use SSL
# FORCE_SSL=1

# mail settings
MAIL_ADDRESS=localhost
MAIL_PORT=25
MAIL_DOMAIN=localhost

# vagrant settings
PRIVATE_IP=10.2.2.4
TRUSTED_IP=10.2.2.1

AWS_KEY=
AWS_SECRET=
AWS_KEYNAME=
AWS_KEYPATH=

ZENODO_KEY=
#ZENODO_URL=https://zenodo.org/api/
ZENODO_URL=https://sandbox.zenodo.org/api/

DO_PROVIDER_TOKEN=
DO_SIZE=1GB
SSH_PRIVATE_KEY='~/.ssh/id_rsa'

# user and group who own application repository
DEPLOY_USER=vagrant
DEPLOY_GROUP=vagrant

LOG_LEVEL=info

# authentication via orcid, github, cas or jwt
OMNIAUTH=orcid

GITHUB_URL=https://github.com/lagotto/lagotto
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

ORCID_CLIENT_ID=
ORCID_CLIENT_SECRET=

CAS_URL=
CAS_INFO_URL=
CAS_PREFIX=

JWT_HOST=
JWT_NAME=
JWT_SECRET_KEY=

# enable logging of external API responses
# LOGSTASH_PATH=log/agent.log

# customize signposts, defaults are shown
# VIEWED=pmc,counter
# SAVED=mendeley,citeulike
# DISCUSSED=twitter,twitter_search,facebook
# CITED=crossref

# don't run rake task from ember-cli-rails gem
SKIP_EMBER = 1

# optionally use Bugsnag, provide API keys here
# BUGSNAG_KEY=
# BUGSNAG_JS_KEY=

# use Atlas for monitoring
# ATLAS_NAME=
# ATLAS_TOKEN=
```

## Automated Installation
This is the recommended way to install Lagotto. The required applications and libraries will automatically be installed in a self-contained virtual machine running Ubuntu 14.04, using [Vagrant] (at least version 1.7.x) and [Chef Solo].

The first step is to copy `.env.example` to `.env` and to set all variables - reasonable defaults are provided for many of them.

Then download and install [Vagrant].

Vagrant needs two additional plugins and will complain if they are missing. The `vagrant-omnibus` plugin installs Chef on the VM, and the `dotenv` gem is used to manage `.env` files.

```sh
vagrant plugin install vagrant-omnibus
vagrant plugin install dotenv
```

The following providers have been tested with Lagotto:

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

For Amazon AWS the configuration could look like this:

```ruby
config.vm.provider :aws do |aws, override|
  # please configure
  aws.access_key_id = ENV['AWS_KEY']
  aws.secret_access_key = ENV['AWS_SECRET']
  aws.keypair_name = ENV['AWS_KEYNAME']
  override.ssh.private_key_path = ENV['AWS_KEYPATH']
  override.vm.hostname = ENV['HOSTNAME']

  aws.security_groups = "default"
  aws.instance_type = "m3.medium"
  aws.ami = "ami-9aaa1cf2"
  aws.region = "us-east-1"
  aws.tags = { Name: 'Vagrant Lagotto' }

  override.ssh.username = "ubuntu"
  override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

  # Custom parameters for the Lagotto recipe
  chef_overrides['lagotto'] = {
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
  override.vm.hostname = ENV['HOSTNAME']
  provider.token = ENV['DO_PROVIDER_TOKEN']
  provider.size = ENV['DO_SIZE'] || '1GB'
  override.ssh.private_key_path = ENV['PRIVATE_KEY_PATH']

  override.vm.box = 'digital_ocean'
  override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  override.ssh.username = "ubuntu"
  provider.region = 'nyc2'
  provider.image = 'Ubuntu 14.04 x64'

  provision(config, override, chef_overrides)
end
```

All user-specific settings are controlled via ENV variables and the `.env` file.

### Cookbooks

The [Chef cookbooks](https://supermarket.getchef.com/) needed by the Lagotto cookbook are managed by [Berkshelf](http://berkshelf.com/), which was installed in a previous step. The required cookbooks are listed in the `Cheffile`, and are automatically installed into `vendor/cookbooks`.

### Installation

Then install the required software for Lagotto with:

```sh
git clone git://github.com/lagotto/lagotto.git
cd lagotto
vagrant up
```

[Virtualbox]: https://www.virtualbox.org/wiki/Downloads
[Vagrant]: http://downloads.vagrantup.com/
[Omnibus]: https://github.com/schisamo/vagrant-omnibus
[Chef Solo]: http://docs.opscode.com/chef_solo.html

This can take up to 15 min, future updates with `vagrant provision` are of course much faster. To get into in the virtual machine, use ssh and then switch to the directory of the application:

```sh
vagrant ssh
cd /var/www/lagotto/current
```

This uses the private SSH key provided by you in the `Vagrantfile` (the default insecure key for local installations using Virtualbox is `~/.vagrant.d/insecure_private_key`). The `vagrant` user has sudo privileges. The MySQL password is stored as `DB_PASSWORD` in the `.env` file. The database servers can be reached from the virtual machine or via port forwarding. Vagrant syncs the folder on the host containing the checked out Lagotto git repo with the folder `/var/www/lagotto` on the guest.

The databases `MySQL` and `Redis` are not installed with the Chef cookbooks, as they typically contain persistent data that should not stored in a temporary virual machine.

## Manual installation
These instructions assume a fresh installation of Ubuntu 14.04 and a user with sudo privileges. Installation on other Unix/Linux platforms should be similar, and Lagotto runs on several production systems with RHEL and CentOS.

#### Add PPAs/repositories to install more recent versions of Ruby and Nginx/Passenger
We only need one Ruby version and manage gems with bundler, so there is no need to install `rvm` or `rbenv`. And we want to install Nginx precompiled with Passenger.

```sh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo apt-get install apt-transport-https ca-certificates -y
sudo apt-get install python-software-properties -y

sudo apt-add-repository ppa:brightbox/ruby-ng

echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' | sudo tee --append /etc/apt/sources.list > /dev/null
```

#### Update package lists

```sh
sudo apt-get update
```

#### Install Ruby and required packages
Also install the `make`, `curl` and `git` packages, the `libmysqlclient-dev` library required by the `myslq2` gem, and `nodejs` as Javascript runtime. When running Lagotto on a local machine we also want to install `avahi-daemon` and `libnss-mdns`for zeroconf networking - this allows us to reach the server at `http://lagotto.local`.

```sh
sudo apt-get install ruby2.2 ruby2.2-dev make curl git libmysqlclient-dev nodejs avahi-daemon libnss-mdns -y
```

#### Install databases

```sh
sudo apt-get install mysql-server redis-server -y
```

#### Install Memcached
Memcached is used to cache requests (in particular API requests), and the default configuration can be used.

```sh
sudo apt-get install memcached -y
```

#### Install Postfix
Postfix is used to send reports via email. The configuration is done in the `.env` file. More information can be found [here](http://guides.rubyonrails.org/action_mailer_basics.html).

```sh
sudo apt-get install postfix -y
```

#### Install Nginx with Passenger

```sh
sudo apt-get install nginx-full passenger -y
```

Edit `/etc/nginx/nginx.conf` and uncomment `passenger_root` and `passenger_ruby`.

#### Set up Nginx virtual host
Please set `server_name` if you have set up more than one virtual host. Use `passenger_app_env development` to use the Rails development environment. Edit the file `/etc/nginx/sites-enabled/default` or - if you use multiple hosts - create the file `/etc/nginx/sites-enabled/lagotto.conf` with the following contents:

```
server {
  listen 80 default_server;
  server_name EXAMPLE.ORG;
  root /var/www/lagotto/public;
  access_log /var/log/nginx/lagotto.access.log;
  passenger_enabled on;
  passenger_app_env production;
}
```

#### Install Lagotto code
You may have to set the permissions first, depending on your server setup. Passenger by default is run by the user who owns `config.ru`.

```sh
mkdir -p /var/www
sudo chmod 755 /var/www
cd /var/www
git clone git://github.com/lagotto/lagotto.git
```

#### Install Bundler and Ruby gems required by the application
Bundler is a tool to manage dependencies of Ruby applications: http://gembundler.com.

```sh
sudo gem install bundler

cd /var/www/lagotto
bundle install
```

#### Install Node, Bower, and npm and bower modules required by the application
[Bower](http://bower.io/) is used to install frontend dependencies (Javascript and CSS libraries). Because of permission issues we don't install Bower globally. Bower modules are installed via a npm postinstall hook.

```sh
cd /var/www/lagotto/frontend
npm install
```

#### Install Lagotto databases
With MySQL we also include all data to get started, including a default user account (`DB_USERNAME` from your `.env` file). Use `RAILS_ENV=production` in your `.env` file if you set up Passenger to run in the production environment.

It is possible to connect Lagotto to MySQL running on a different server, please change `DB_HOST` in your `.env` file accordingly. We are using the default installation for redis.

```sh
cd /var/www/lagotto
rake db:setup RAILS_ENV=production
```

#### Restart Nginx
We are making `lagotto` the default site.

```sh
sudo service nginx restart
```

You can now access the Lagotto application with your web browser at the name or IP address of your Ubuntu installation.

## Using PostgreSQL instead of MySQL
The instructions above are for using MySQL, but Lagotto can also be installed with PostgreSQL. Change the database adapter in `config/database.yml` to use PostgreSQL by adding `DB=postgres` to your `.env` file.

```yaml
mysql: &mysql
  adapter: mysql2

postgresql: &postgres
  adapter: postgresql
  pool: 10
  min_messages: ERROR

defaults: &defaults
  pool: 5
  timeout: 5000
  database: <%= ENV['DB_NAME'] %>
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] %>

  <<: *<%= ENV['DB'] || "mysql" %>

  development:
  <<: *defaults

  test:
    <<: *defaults

  production:
    <<: *defaults
```

Make sure the `pg` gem is included in your `Gemfile` and you have installed Postgres and the required libraries with

```sh
sudo apt-get install postgresql libpq-dev -y
```

## Running Lagotto on multiple servers

Lagotto was developed to run on a single server, but most components scale to multiple servers. When running Lagotto on multiple servers, make sure that:

* the name of load balancer is set as `SERVERNAME` in `.env`
* memcached should be set up as a cluster by adding a `MEMCACHE_SERVERS` comma-separated list with all Lagotto servers behind the load balancer to `.env`, e.g. `MEMCACHE_SERVERS=example1.org,example2.org`
* workers should run on only one server, e.g. the server with the capistrano `:db` role
* database maintenance rake tasks should run on only one server, capistrano defaults to install the cron jobs only for the `:db` role.
* mail services (sending emails) should run on only one server. They are part of the database maintenance tasks, so by default run only on the server with the `:db` role.
