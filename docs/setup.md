---
layout: card_list
title: Setup
---

## Adding Users
Lagotto supports the following user roles:

* API user - only API key
* contributor - add content via the deposit API
* staff - read-only access to admin area
* admin - full access to admin area

Lagotto supports the following forms of authentication:

* authentication with [ORCID](http://www.orcid.org/)
* authentication with [Github](https://developer.github.com/guides/basics-of-authentication/)
* authentication with [JWT](https://jwt.io)
* authentication with (currently PLOS only)

Authentication with [Mozilla Persona](https://login.persona.org/) was removed, as the service will be discontinued by the end of 2016. Authentication via username/password is not supported.

Only one authentication method can ab enabled at a time. The first user created in the system automatically has an admin role, and this user can be created with any of the authentication methods listed above. From then on all user accounts are created with an API user role, and users have to create their own account using third-party authentication . Admin users can change the user role after an account has been created, but can't create user accounts

Third-party authentication is configured in `.env`, using the `OMNIAUTH` variable. Configuration settings for ORCID, CAS, Github and JWT are also provided via ENV variables.

Users automatically obtain an API key. Admin users can sign up for additional reports (error report, status report, disabled source report).

## Configuring Agents and Sources

Agents and sources have to be installed and activated through the web interface `Agents -> Installation` and `Sources -> Installation` :

![Installation](/images/installation.png)

All agents can be installed, but some sources require additional configuration settings such as API keys before they can be activated. The [documentation for agents](agents) contains information about how to obtain API keys and other required agent-specific settings.

The following addiotional configuration options are available via the web interface:

* whether the results can be shared via the API (default true)
* rate-limiting (default 10,000)
* timeout (default 30 sec)
* maximum number of failed queries allowed before being disabled (default 200)

![Configuration](/images/configuration.png)

Through these setup options the behavior of sources can be fine-tuned, but the default settings should almost always work. The default rate-limiting settings should only be increased if your application has been whitelisted with that agent.

Some agents (currently *PubMed Central Usage Stats* and *CrossRef*) also have publisher-specific settings. You need to add at least one publisher via the web interface and associate your account with a publisher. You then see an additional configuration tab **Publisher** configuration.

## Adding, updating or deleting works, contributors or publishers
Content is added via the deposits API. Import via command line, as in previous Lagotto versions, is no longer supported. Lagotto provides a large number of built-in agents for most of these tasks, or content is added via external agents.

The deposits API is described in more detail [here](/docs/deposits).

## Starting Workers
Lagotto talks to external data sources to collect information about works in the background, using the [sidekiq](https://github.com/mperham/sidekiq) queuing system and Rails ActiveJob framework. The results are stored in MySQL. This can be done in one of two ways:

### Ad-hoc workers
To collect metrics once for a set of works, or for testing purposes the workers can be run ad-hoc using the `bundle exec sidekiq` command.

You then have to decide what works you want updated. This can be either all works, all works for a list of specified sources, or all works published in a specific time interval. Issue one of the following commands (and include `RAILS_ENV=production` in production mode):

```sh
bundle exec rake queue:all
bundle exec rake queue:all[pubmed,mendeley]
bundle exec rake queue:all FROM_DATE=2013-02-01 UNTIL_DATE=2014-02-08
bundle exec rake queue:all[pubmed,mendeley] FROM_DATE=2013-02-01 UNTIL_DATE=2014-02-08
```

You can then start the workers with:

```sh
bundle exec rake sidekiq:start
```

### Background workers
In a continously updating production system we want to run Sidekiq in the background with the above command. You can monitor the Sidekiq status in the admin dashboard (`/status`).

When we have to update the metrics for a work, a job is added to the background queue for that source. Sidekiq will then process this job in the background. By default Sidekiq runs 25 processes in parallel.

### List of background jobs that Lagotto uses

We have the following background queues sorted by decreasing priority:

* **critical**
* **high**
* **default**
* **low**
* **mailers**

Jobs for agents go into the `default` queue, unless the agent was configured to use the `high` or `low` queue.

## Configuring Maintenance Tasks
Lagotto uses a number of maintenance tasks in production mode - they are not necessary for a development instance.

Many of the maintenance taks are `rake` tasks, and they are listed on a [separate page](/docs/rake). All rake tasks are issued from the application root folder. You want to prepend your rake command with `bundle exec` and `RAILS_ENV=production` should be appended to the rake command when running in production, e.g.

```sh
bin/rake db:works:load <IMPORT.TXT RAILS_ENV=production
```

### Cron jobs
Lagotto uses the [Whenever](https://github.com/javan/whenever) gem to make it easy to generate cron jobs. The configuration is stored in `config/schedule.rb`:

```ruby
env :PATH, ENV['PATH']
env :DOTENV, ENV['DOTENV']
set :environment, ENV['RAILS_ENV']
set :output, "log/cron.log"

# Schedule jobs
# Send report when workers are not running
# Create notifications by filtering API responses and mail them
# Delete resolved notifications
# Delete API request information, keeping the last 1,000 requests
# Delete API response information, keeping responses from the last 24 hours
# Generate a monthly report

# every hour at 10 min past the hour
every "10 * * * *" do
  rake "cron:hourly"
end

every 1.day, at: "1:20 AM" do
  rake "cron:daily"
end

every :monday, at: "1:40 AM" do
  rake "cron:weekly"
end

# every 10th of the month at 2:10 AM
every "50 2 10 * *" do
  rake "cron:monthly"
end
```

You can display this information in cron format by:

```sh
bundle exec whenever
```
To write this information to your crontab file, use

```sh
bundle exec whenever --update-crontab lagotto
```

The crontab is automatically updated when you run capistrano (see [Installation](/docs/installation)).

### Filters
Filters check all API responses of the last 24 hours for errors and potential anti-gaming activity, and they are typically run as cron job. They can be activated and configured (e.g. to set limits) individually in the admin panel:

![Filters](/images/filters.png)

These filters will generate notifications that are displayed in the admin panel in various places. More information is available on the [Notifications](/docs/Notifications) page.

### Reports
Lagotto generates a number of email reports that are available to admin and staff accounts.

![Profile](/images/profile.png)

Lagotto installs the **Postfix** mailer and the default settings should work in most cases. Mail can otherwise me configure in the `.env` file:

```
MAIL_ADDRESS=localhost
MAIL_PORT=25
MAIL_DOMAIN=localhost
```

The reports are generated via the cron jobs mentioned above. Make sure you have correct write permissions for the Work Statistics Report, it is recommended to run the rake task at least once to test for this:

```sh
bundle exec rake report:all_stats RAILS_ENV=production
```

This rake task generates the monthly report file and this file is then available for download from the [Zenodo](https://zenodo.org/) data repository. Make sure the `ZENODO_API_KEY`, `SITENAMELONG` and `CREATOR` ENV variables are set correctly. Users who have signed up for this report will be notified by email when the report has been generated.

### Snapshotting the API

Lagotto provides the capability to snapshot its API at a given point in time. This makes it possible to download the full data-set from one or more API end-points which can be useful for loading the data into a different system for analysis.

By default, Lagotto will create a snapshot of an end-point, zip it up, and upload it to [Zenodo](http://zenodo.org).

#### Available end-points

To see what end-points are available for snapshotting run the following rake command:

```
bin/rake -T api:snapshot
```

#### Creating Snapshots

You can create snapshots by running the below rake tasks:

* `bundle exec rake api:snapshot:events` - snapshot just the events API
* `bbundle exec rake api:snapshot:references` - snapshot just the references API
* `bbundle exec rake api:snapshot:works` - snapshot just the works API
* `bundle exec rake api:snapshot:all` - snapshot all three of the API end-points above

#### Environment Requirements

This requires [Zenodo integration](https://zenodo.org/dev) and expects the following environment variables to be configured:

* SERVERNAME: this is used to determine what host to snapshot.
* ZENODO_KEY: used in posting the zip file to Zenodo
* ZENODO_URL: used in posting the zip file to Zenodo
* APPLICATION: used in posting the zip file to Zenodo
* CREATOR: used in posting the zip file to Zenodo
* SITENAMELONG: used in posting the zip file to Zenodo
* GITHUB_URL: used in posting the zip file to Zenodo

Also, you must be running Sidekiq (bin/rake sidekiq:start) in order for the APIs to be snapshotted as the work is done in the background.

_Note: you can register a test Zenodo account using https://sandbox.zenodo.org before integrating with their production environment. Just update the ZENODO_URL and ZENODO_KEY environment variables accordingly._

#### Optional environment variables

The below environment variables can be set to test creating snapshots. It is useful for manual testing and exploration:

* START_PAGE: the page number to start on. The default is nil so it will start on the root page.
* STOP_PAGE: the page number to stop crawling on (even if there are more pages). The default is nil so it will stop only when there are no more pages to crawl.
* PAGES_PER_JOB: the number of pages to process per `ApiSnapshotJob`. The default is 10.
* BENCHMARK: set if you want to benchmark how long each requests takes. This will create a file in the same location as the jsondump file and will append the suffix `.benchmark`. E.g. `api_works.jsondump.benchmark`
* FILENAME_EXT - this is the filename extension to be used to dump the file. The default is `jsondump`.
* SNAPSHOT_DIR: the directory to store snapshots in. The default is `LAGOTTO_ROOT/tmp/snapshots/snapshot_YYYY-MM-DD`.

An easy way to test this locally is to run the following:

```
# Make sure sidekiq is running fresh code
bundle exec rake sidekiq:stop && bundle exec rake sidekiq:start

# Queue up our snapshots and benchmark them
STOP_PAGE=2 BENCHMARK=1 bundle exec rake api:snapshot:all
```
