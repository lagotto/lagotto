---
layout: page
title: "Installation"
---

ALM is a typical Ruby on Rails web application with one unusual feature: it requires the CouchDB database. CouchDB is used to store the responses from external API calls, MySQL (or PostgreSQL, see below) is used for everything else. The application has been tested with Apache/Passenger, but should also run in other deployment environments, e.g. Nginx/Unicorn or WEBrick. ALM uses Ruby on Rails 3.2.x, migration to Rails 4.x is planned for 2014. The application has extensive test coverage using [Rspec] and [Cucumber].

[Rspec]: http://rspec.info/
[Cucumber]: http://cukes.info/

The ALM application is available as Open Source software using a [Apache license](http://www.apache.org/licenses/LICENSE-2.0.html), all dependencies (software and libraries) are also Open Source.

Because of the background workers that talk to external APIs we recommend at least 1 Gb of RAM, and more if you have a large number of articles. As a rule of thumb you need one worker per 5,000 - 20,000 articles, and 1 Gb of RAM per 10 workers - the exact numbers depend on how often you plan to update articles, e.g. you need more workers if you plan on update your usage stats every day.

#### Ruby
ALM requires Ruby 1.9.3 or greater, and has been tested with Ruby 1.9.3, 2.0 and 2.1. Not all Linux distributions include Ruby 1.9 as a standard install, which makes it more difficult than it should be. [RVM] and [Rbenv] are Ruby version management tools for installing Ruby 1.9. Unfortunately they also introduce additional dependencies, making them sometimes not the best choices in a production environment. The Chef script below installs Ruby 2.1.

[RVM]: http://rvm.io/
[Rbenv]: https://github.com/sstephenson/rbenv

#### Installation Options

* automated installation via Vagrant and Capistrano (recommended)
* manual installation

Hosting the ALM application at a Platform as a Service (PaaS) provider such as Heroku or OpenShift is possible, but has not been tested.

## Automated Installation
This is the recommended way to install the ALM application. The required applications and libraries will automatically be installed in a self-contained virtual machine, using [Vagrant] and [Chef Solo]. We use the [Capistrano](http://capistranorb.com/) deployment tool to install the latest ALM code, run database migrations and restart the server.

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

Some custom settings for the virtual machine are stored in the `Vagrantfile`, and that includes your cloud provider access keys, the ID base virtual machine with Ubuntu 12.04 from by your cloud provider, RAM for the virtual machine, and networking settings for a local installation. A sample configuration for AWS would look like:

```ruby
config.vm.hostname = "SUBDOMAIN.EXAMPLE.ORG"

config.vm.provider :aws do |aws, override|
  aws.access_key_id = "EXAMPLE"
  aws.secret_access_key = "EXAMPLE"
  aws.keypair_name = "EXAMPLE"
  aws.security_groups = ["EXAMPLE"]
  aws.instance_type = 'm1.small'
  aws.ami = "ami-e7582d8e"
  aws.tags = { Name: 'Vagrant alm' }

  override.ssh.username = "ubuntu"
  override.ssh.private_key_path = "/EXAMPLE.pem"
end
```
For Digital Ocean the configuration could look like this:

```ruby
config.vm.hostname = "SUBDOMAIN.EXAMPLE.ORG"

config.vm.provider :digital_ocean do |provider, override|
  override.ssh.private_key_path = '~/.ssh/id_rsa'
  override.vm.box = 'digital_ocean'
  override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  override.ssh.username = "ubuntu"

  provider.region = 'nyc2'
  provider.image = 'Ubuntu 12.04.4 x64'
  provider.size = '1GB'

  # please configure
  override.vm.hostname = "ALM.EXAMPLE.ORG"
  provider.token = 'EXAMPLE'
end
```

The sample configurations for AWS and Digital Ocean is included in the `Vagrantfile`.

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

This can take up to 15 min, future updates with `vagrant provision` are of course much faster. To get into in the virtual machine, use user `vagrant` with password `vagrant` or do:

```sh
vagrant ssh
cd /vagrant
```

This uses the private SSH key provided by you in the `Vagrantfile` (the default insecure key for local installations using Virtualbox is `~/.vagrant.d/insecure_private_key`). The `vagrant` user has sudo privileges. The MySQL password is stored at `config/database.yml`, and is auto-generated during the installation. CouchDB is set up to run in **Admin Party** mode, i.e. without usernames or passwords. The database servers can be reached from the virtual machine or via port forwarding (configured in `Vagrantfile`). Vagrant syncs the folder on the host containing the checked out ALM git repo with the folder `/var/www/alm/shared` on the guest.

## Deployment via Capistrano
Using the deployment automation tool [Capistrano](http://capistranorb.com) is the recommended strategy for code updates via git, database migrations and server restarts. Capistrano assumes that the server has been provisioned using Vagrant or Chef (or via manual installation, see below).

To use Capistrano you need Ruby (at least 1.9.3) installed on your local machine. If you haven't done so, install [Bundler](http://bundler.io/) to manage the dependencies for the ALM application:

```sh
gem install bundler
```

Then go to the ALM git repo that you probably have already cloned in the installation step and install all required dependencies.

```sh
git clone git://github.com/articlemetrics/alm.git
cd alm
bundle install
```

#### Edit deployment configuration
The deployment settings for the development environment and the Virtualbox VM created by Vagrant is already configured:

```ruby
set :stage, :development
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "develop"
set :deploy_user, 'vagrant'
set :rails_env, :development

# install all gems into system
set :bundle_without, nil
set :bundle_binstubs, nil
set :bundle_path, nil
set :bundle_flags, '--system'

# don't precompile assets
set :assets_roles, []

server '33.33.33.44', roles: %w{web app db}

set :ssh_options, {
  user: "vagrant",
  keys: %w(~/.vagrant.d/insecure_private_key),
  auth_methods: %w(publickey)
}

# Set number of delayed_job workers
set :delayed_job_args, "-n 3"
```

For a different setup (e.g. a production server) edit the deployment configuration for Capistrano by renaming the file `config/deploy/production.rb.example` to `config/deploy/production.rb` and fill in the following information:

* server for roles :app, :web, :db (name or IP address, could all be the same server)
* :deploy_user
* number of background workers, e.g. three workers: :delayed_job_args, "-n 3"
* SSH keys via :ssh_options

A sample `config/deploy/production.rb` could look like this:

```ruby
set :stage, :production
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"
set :deploy_user, 'ubuntu'
set :rails_env, :production

role :app, %w{ALM.EXAMPLE.ORG}
role :web, %w{ALM.EXAMPLE.ORG}
role :db,  %w{ALM.EXAMPLE.ORG}

set :ssh_options, {
  user: "ubuntu",
  keys: %w(~/.ssh/id_rsa),
  auth_methods: %w(publickey)
}

# Set number of delayed_job workers
set :delayed_job_args, "-n 6"
```

#### Deploy
We deploy the ALM application with

```sh
bundle exec cap production deploy
```

Replace `production` with `staging` or `development` for other environments. You can pass in environment variables, e.g. to deploy a different git branch: `cap production deploy BRANCH_NAME=develop`.

The first time this command is run it creates the folder structure required by Capistrano, by default in `/var/www/alm`. To make sure the expected folder structure is created successfully you can run:

```sh
bundle exec cap production deploy:check
```

On subsequent runs the command will pull the latest code from the Github repo, run database migrations, install the dependencies via Bundler, stop and start the background workers, updates the crontab file for ALM, and in production mode precompiles assets (CSS, Javascripts, images).

## Manual installation
These instructions assume a fresh installation of Ubuntu 12.04 and a user with sudo privileges. Installation on other Unix/Linux platforms should be similar, but may require additional steps to install Ruby 1.9.

#### Update package lists

```sh
sudo apt-get update
```

#### Install required packages
`libxml2-dev` and `libxslt1-dev` are required for XML processing by the `nokogiri` gem, `nodejs` provides Javascript for the `therubyracer` gem.

```sh
sudo apt-get install curl build-essential git-core libxml2-dev libxslt1-dev nodejs
```

#### Install Ruby 1.9.3
We only need one Ruby version and manage gems with bundler, so there is no need to install `rvm` or `rbenv`.

```sh
sudo apt-get install ruby1.9.3
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

#### Install Apache and dependencies required for Passenger

```sh
sudo apt-get install apache2 apache2-prefork-dev libapr1-dev libaprutil1-dev libcurl4-openssl-dev
```

#### Install and configure Passenger
Passenger is a Rails application server: http://www.modrails.com. Update `passenger.load` and `passenger.conf` when you install a new version of the passenger gem.

```sh
sudo gem install passenger -v 4.0.41
sudo passenger-install-apache2-module --auto

# /etc/apache2/mods-available/passenger.load
LoadModule passenger_module /var/lib/gems/1.9.1/gems/passenger-4.0.41/ext/apache2/mod_passenger.so

# /etc/apache2/mods-available/passenger.conf
PassengerRoot /var/lib/gems/1.9.1/gems/passenger-4.0.41
PassengerRuby /usr/bin/ruby1.9.1

sudo a2enmod passenger
```

#### Set up virtual host
Please set `ServerName` if you have set up more than one virtual host. Also don't forget to add`AllowEncodedSlashes On` to the Apache virtual host file in order to keep Apache from messing up encoded embedded slashes in DOIs. Use `RailsEnv development` to use the Rails development environment.

```apache
# /etc/apache2/sites-available/alm
<VirtualHost *:80>
  ServerName localhost
  RailsEnv production
  DocumentRoot /var/www/alm/public

  <Directory /var/www/alm/public>
    Options FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
  </Directory>

  # Important for ALM: keeps Apache from messing up encoded embedded slashes in DOIs
  AllowEncodedSlashes On

</VirtualHost>
```

#### Install ALM code
You may have to set the permissions first, depending on your server setup. Passenger by default is run by the user who owns `config.ru`.

```sh
git clone git://github.com/articlemetrics/alm.git /var/www/alm
```

#### Install Bundler and Ruby gems required by the application
Bundler is a tool to manage dependencies of Ruby applications: http://gembundler.com. We have to install `therubyracer` gem as sudo because of a permission problem (make sure the version matches the version in `Gemfile` in the ALM root directory).

```sh
sudo gem install bundler
sudo gem install therubyracer -v '0.12.0'

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
rake db:setup RAILS_ENV=development
curl -X PUT http://localhost:5984/alm/
```

#### Start Apache
We are making `alm` the default site.

```sh
sudo a2dissite default
sudo a2ensite alm
sudo service apache2 reload
```

You can now access the ALM application with your web browser at the name or IP address (if it is the only virtual host) of your Ubuntu installation.

## Using PostgreSQL instead of MySQL
The instructions above are for using MySQL, but the ALM application can also be installed with PostgreSQL with two small changes:

### Install PostgreSQL gem
Uncomment `gem 'pg'` in your `Gemfile`, comment out `gem 'mysql2'` and run `bundle update`:

```ruby
gem 'rails', '3.2.16'
#gem 'mysql2', '0.3.13'
gem 'pg', '~> 0.17.1'
```

### Change database adapter
Change the adapter in `config/database.yml` to use PostgreSQL instead of MySQL (change the line in defaults to `<<:postgres`):

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
