---
layout: card_list
title: "Rake"
---

## Introduction

There are several Lagotto-specific rake tasks that help with administration of the Lagotto application. They can be listed with the following command:

```sh
bundle exec rake -T
```

Please prepend `RAILS_ENV=production` to all rake commands when running Rails in `production` mode.

## api.rake

Lagotto provides the capability to snapshot its API at a given point in time. This makes it possible to download the full data-set from one or more API end-points which can be useful for loading the data into a different system for analysis.

By default, Lagotto will create a snapshot of an end-point, zip it up, and upload it to [Zenodo](http://zenodo.org).

#### Available end-points

To see what end-points are available for snapshotting run the following rake command:

```
bundle exec rake -T api:snapshot
```

#### Creating Snapshots

You can create snapshots by running the below rake tasks:

* `bundle exec rake api:snapshot:events` - snapshot just the events API
* `bundle exec rake api:snapshot:references` - snapshot just the references API
* `bundle exec rake api:snapshot:works` - snapshot just the works API
* `bundle exec rake api:snapshot:all` - snapshot all three of the API end-points above

## db.rake

Deletes works and associated rows in the events table. Use `PUBLISHER_ID` to delete works from a particular publisher, or `PUBLISHER_ID=all" to delete all works.

```sh
bundle exec rake db:works:delete PUBLISHER_ID=340
```

Removes all HTML and XML tags from title field (for legacy data).

```sh
bundle exec rake db:works:sanitize_title
```

Install agents. Provide one or more agent names as arguments, e.g. `rake db:agents:install[pmc]` or install all available agents without arguments:

```sh
bundle exec rake db:agents:install
```

Uninstall agents. Provide one or more agent names as arguments, e.g. `rake db:agents:uninstall[pmc]`:

```sh
bundle exec rake db:agents:uninstall
```

Deletes all resolved notifications:

```sh
bundle exec rake db:notifications:delete
```

Delete old API requests (only keep the last 10,000):

```sh
bundle exec rake db:api_requests:delete
```

Delete all resolved API responses older than 24 hours:

```sh
bundle exec rake db:api_responses:delete
```

The last three rake tasks should run regularly, and can be set up to run as a daily cron task with `bundle exec whenever -w`.

## queue.rake

Queue all works

```sh
bundle exec rake queue:all
```

By default the rake tasks above run for all agents. Do have them run for one or more specific agents, add the source names as parameters:

```sh
bundle exec rake queue:all[mendeley,citeulike]
```

## report.rake

Generate all work stats reports.

```sh
bundle exec rake report:all_stats
```

Generate CSV file with Lagotto stats for private and public sources.

```sh
bundle exec rake report:alm_private_stats
```

Generate CSV file with Lagotto stats for public sources.

```sh
bundle exec rake report:alm_stats
```

Zip reports.

```sh
bundle exec rake report:zip
```

## sidekiq.rake

Start Sidekiq background processes.

```sh
bundle exec rake sidekiq:start
```

Stop Sidekiq background processes.

```sh
bundle exec rake sidekiq:stop
```

Stop Sidekiq background processes to accept new work.

```sh
bundle exec rake sidekiq:quiet
```

Check status of Sidekiq background processes.

```sh
bundle exec rake sidekiq:monitor
```

## filter.rake

Create notifications by filtering API responses

```sh
bundle exec rake filter:all
```

Unresolve all notifications that have been filtered (e.g. to re-run filters with new settings)

```sh
bundle exec rake filter:unresolve
```

## mailer.rake

Send all reports

```sh
bundle exec rake mailer:all
```

Send error report

```sh
bundle exec rake mailer:error_report
```

Send status report

```sh
bundle exec rake mailer:status_report
```
