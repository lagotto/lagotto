---
layout: card_list
title: "Rake"
---

## Introduction

There are several ALM-specific rake tasks that help with administration of the ALM application. They can be listed with the following command:

```sh
bin/rake -T
```

Please prepend `RAILS_ENV=production` to all rake commands when running Rails in `production` mode.

## db.rake

Bulk-load works via the CrossRef API:

```sh
bin/rake db:works:import:crossref
```

The command takes the following optional parameters via ENV variables

```sh
FROM_UPDATE_DATE=2014-02-05
UNTIL_UPDATE_DATE=2014-03
FROM_PUB_DATE=2014-01-01
UNTIL_UPDATE_DATE=2014-07-01
MEMBER=340
TYPE=journal-work
ISSN=1545-7885
SAMPLE=50
```

* `FROM_UPDATE_DATE` means metadata updated since (inclusive) `{date}`, `UNTIL_UPDATE_DATE` means metadata updated until (inclusive) `{date}`, it defaults to today.
* `FROM_PUB_DATE` means work published since (inclusive) `{date}`, `UNTIL_PUB_DATE` published until (inclusive) `{date}`.
* `MEMBER` is the CrossRef member_id, which you find by searching the member database, e.g. `http://api.crossref.org/members?query=elife`.
   If you have `import=member` in `.env`, then the rake task will use the CrossRef member_id of all publishers added via the web interface.
   Using `MEMBER` as ENV variable will instead import DOIs for that CrossRef member.
* `TYPE` is the type of the resource, e.g. `journal-work`, a listing of available types can be found at `http://api.crossref.org/types`.
* `SAMPLE` returns a random sample of x DOIs and can be combined with the other parameters.

For more information please see the [CrossRef API documentation](https://github.com/CrossRef/rest-api-doc/blob/master/funder_kpi_api.md).

To load for example all eLife content created or updated in 2014, use the following command:

```sh
bin/rake db:works:import:crossref MEMBER=4374 FROM_UPDATE_DATE=2014 UNTIL_UPDATE_DATE=2014-12
```

When `import=member` or `import=member_sample` is set in the configuration, the `MEMBER` parameter can be ignored.

Bulk-load works via the DataCite API:

```sh
bin/rake db:works:import:datacite
```

The command takes the following optional parameters via ENV variables

```sh
FROM_UPDATE_DATE=2014-02-05
UNTIL_UPDATE_DATE=2014-03
FROM_PUB_DATE=2014-01-01
UNTIL_UPDATE_DATE=2014-07-01
MEMBER=CDL.DRYAD
TYPE=Dataset
```

Bulk-load works via the PLOS Search API:

```sh
bin/rake db:works:import:plos
```

The command takes the following optional parameters via ENV variables

```sh
FROM_PUB_DATE=2014-01-01
UNTIL_UPDATE_DATE=2014-07-01
```

Bulk-load a file consisting of DOIs, one per line. It'll ignore (but count) invalid ones and those that already exist in the database:

```sh
bin/rake db:articles:load <DOI_DUMP
```

Format for import file

```sh
DOI Date(YYYY-MM-DD) Title
```

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

Deletes works and associated rows in the retrieval_statuses table. Use `MEMBER` to delete works from a particular publisher, or `MEMBER=all" to delete all works.

```sh
bin/rake db:works:delete MEMBER=340
```

Removes all HTML and XML tags from title field (for legacy data).

```sh
bin/rake db:works:sanitize_title
```

Isnstall sources. Provide one or more source names as arguments, e.g. `rake db:sources:install[pmc]` or install all available sources without arguments:

```sh
bin/rake db:sources:install
```

Uninstall sources. Provide one or more source names as arguments, e.g. `rake db:sources:uninstall[pmc]`:

```sh
bin/rake db:sources:uninstall
```

Deletes all resolved alerts:

```sh
bin/rake db:alerts:delete
```

Delete old API requests (only keep the last 10,000):

```sh
bin/rake db:api_requests:delete
```

Delete all resolved API responses older than 24 hours:

```sh
bin/rake db:api_responses:delete
```

The last three rake tasks should run regularly, and can be set up to run as a daily cron task with `bundle exec whenever -w`.

## queue.rake

Queue all works

```sh
bin/rake queue:all
```

Queue work with given pid:

```sh
bin/rake queue:one[pid]
```

By default the rake tasks above run for all sources. Do have them run for one or more specific sources, add the source names as parameters:

```sh
bin/rake queue:all[mendeley,citeulike]
```

## pmc.rake

Import latest (i.e. last month's) PubMed Central usage stats.

```sh
bin/rake pmc:update
```

Import all PubMed Central usage stats since month/year.

```sh
bin/rake pmc:update MONTH=1 YEAR=2013
```

## report.rake

Generate all work stats reports.

```sh
bin/rake report:all_stats
```

Generate CSV file with ALM stats for private and public sources.

```sh
bin/rake report:alm_private_stats
```

Generate CSV file with ALM stats for public sources.

```sh
bin/rake report:alm_stats
```

Generate CSV file with combined ALM private and public sources.

```sh
bin/rake report:combined_private_stats
```

Generate CSV file with combined ALM stats.

```sh
bin/rake report:combined_stats
```

Generate CSV file with Counter usage stats.

```sh
bin/rake report:counter
```

Generate CSV file with Counter combined usage stats.

```sh
bin/rake report:counter_combined_stats
```

Generate CSV file with Counter HTML usage stats.

```sh
bin/rake report:counter_html_stats
```

Generate CSV file with Counter PDF usage stats.

```sh
bin/rake report:counter_pdf_stats
```

Generate CSV file with cumulative Counter usage stats.

```sh
bin/rake report:counter_stats
```

Generate CSV file with Counter XML usage stats.

```sh
bin/rake report:counter_xml_stats
```

Generate CSV file with Mendeley stats.

```sh
bin/rake report:mendeley_stats
```

Generate CSV file with PMC usage stats.

```sh
bin/rake report:pmc
```

Generate CSV file with PMC combined usage stats.

```sh
bin/rake report:pmc_combined_stats
```

Generate CSV file with PMC HTML usage stats over time.

```sh
bin/rake report:pmc_html_stats
```

Generate CSV file with PMC PDF usage stats over time.

```sh
bin/rake report:pmc_pdf_stats
```

Generate CSV file with PMC cumulative usage stats.

```sh
bin/rake report:pmc_stats
```

Zip reports.

```sh
bin/rake report:zip
```

## sidekiq.rake

Start Sidekiq background processes.

```sh
bin/rake sidekiq:start
```

Stop Sidekiq background processes.

```sh
bin/rake sidekiq:stop
```

Stop Sidekiq background processes to accept new work.

```sh
bin/rake sidekiq:quiet
```

Check status of Sidekiq background processes.

```sh
bin/rake sidekiq:monitor
```

## filter.rake

Create alerts by filtering API responses

```sh
bin/rake filter:all
```

Unresolve all alerts that have been filtered (e.g. to re-run filters with new settings)

```sh
bin/rake filter:unresolve
```

## mailer.rake

Send all reports

```sh
bin/rake mailer:all
```

Send error report

```sh
bin/rake mailer:error_report
```

Send status report

```sh
bin/rake mailer:status_report
```
