---
layout: card
title: "Deployment"
---

[Installation](/docs/installation.md) installs all required software and code. From then on all code updates - including database migrations - are much easier as we no longer need to install Ruby, Nginx, MySQL, etc.:

* on local installations (e.g. using Virtualbox) update all code with `git pull`, run databases migrations if necessary with `bundle exec rake db:migrate`, if necessary update the installed Ruby gems via `bundle update`, and then restart the Rails application server with `touch tmp/restart.txt`.
* on remote installations (e.g. using AWS) use the [Capistrano](http://capistranorb.com) deployment automation tool.
* alternatively, on remote installations (e.g. using AWS) use the [Packer](http://packer.io) deployment automation tool.

Capistrano is the most commonly used deployment automation tool for Rails. Packer is better suited for workflows where a new virtual machine is created for every deployment.

## Deployment via Capistrano
Capistrano greatly simplifies the code updates via git, database migrations and server restarts on a remote machine. Capistrano assumes that the server has been provisioned using Vagrant/Chef or via manual installation (see [Installation](/docs/installation.md)). Capistrano runs on your local machine.

To use Capistrano you need Ruby (at least 2.2) installed on your local machine. If you haven't done so, install [Bundler](http://bundler.io/) to manage the dependencies for Lagotto:

```sh
gem install bundler
```

Then go to the Lagotto git repo that you probably have already cloned in the installation step and install all required dependencies.

```sh
git clone git://github.com/lagotto/lagotto.git
cd lagotto
bundle install
```

#### Edit deployment configuration
Edit the deployment configuration for a production server in the `.env` file in the local Lagotto root folder. The samae file needs to go to `/var/www/lagotto/shared/.env` on the production server.

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

## Deployment via Packer

Packer can be used as a standalone tool, or in combination with the [Atlas](https://atlas.hashicorp.com) service. to build an image file locally, run

```sh
packer build template.json
```

To have the Atlas service build the image file, run:

```sh
packer push -name=ATLAS_ACCOUNT/ATLAS_NAME template.json

``

The packer configuration file is `template.json` in the application root folder, and is configured to build an Amazon AMI. Packer can also build images in other formats, e.g. for Digital Ocean.
