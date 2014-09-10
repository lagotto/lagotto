---
layout: page
title: "Deployment"
---

[Installation](/docs/installation.md) installs all required software and code. From then on all code updates - including database migrations - are much easier as we no longer need to install Ruby, Nginx, MySQL, etc.:

* on local installations (e.g. using Virtualbox) update all code with `git pull`, run databases migrations if necessary with `bundle exec rake db:migrate`, if necessary update the installed Ruby gems via `bundle update`, and then restart the Rails application server with `touch tmp/restart.txt`.
* on remote installations (e.g. using AWS) use the [Capistrano](http://capistranorb.com) deployment automation tool.

## Deployment via Capistrano
Capistrano greatly simplifies the code updates via git, database migrations and server restarts on a remote machine. Capistrano assumes that the server has been provisioned using Vagrant/Chef or via manual installation (see [Installation](/docs/installation.md)). Capistrano runs on your local machine.

To use Capistrano you need Ruby (at least 1.9.3) installed on your local machine. If you haven't done so, install [Bundler](http://bundler.io/) to manage the dependencies for Lagotto:

```sh
gem install bundler
```

Then go to the Lagotto git repo that you probably have already cloned in the installation step and install all required dependencies.

```sh
git clone git://github.com/articlemetrics/lagotto.git
cd lagotto
bundle install
```

#### Edit deployment configuration
Edit the deployment configuration for a production server by renaming the file `config/deploy/production.rb.example` to `config/deploy/production.rb` and fill in the following information:

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

server 'EXAMPLE.ORG', roles: %w{web app db}

set :ssh_options, {
  user: "ubuntu",
  keys: %w(~/.ssh/id_rsa),
  auth_methods: %w(publickey)
}

# Set number of delayed_job workers
set :delayed_job_args, "-n 6"
```

#### Deploy
We deploy Lagotto with

```sh
bundle exec cap production deploy
```

You can replace `production` with other environments, e.g. `staging`. You can pass in environment variables, e.g. to deploy a different git branch: `cap production deploy BRANCH_NAME=develop`.

The first time this command is run it creates the folder structure required by Capistrano, by default in `/var/www/lagotto`. To make sure the expected folder structure is created successfully you can run:

```sh
bundle exec cap production deploy:check
```

On subsequent runs the command will pull the latest code from the Github repo, run database migrations, install the dependencies via Bundler, stop and start the background workers, updates the crontab file for Lagotto, and precompiles assets (CSS, Javascripts, images).
