---
layout: page
title: "Rake"
---

There are several ALM-specific rake tasks that help with administration of the ALM application. They can be listed with the following command:

```sh
bundle exec rake -T
```

Please append `RAILS_ENV=production` to all rake commands when running Rails in `production` mode.

### db.rake

Bulk-load articles via the CrossRef API:

```sh
bundle exec rake db:articles:import
```

The command takes the following optional parameters via ENV variables

```sh
FROM_UPDATE_DATE=2014-02-05
UNTIL_UPDATE_DATE=2014-03
FROM_PUB_DATE=2014-01-01
UNTIL_UPDATE_DATE=2014-07-01
MEMBER=340
TYPE=journal-article
ISSN=1545-7885
SAMPLE=50
```

* `FROM_UPDATE_DATE` means metadata updated since (inclusive) `{date}`, `UNTIL_UPDATE_DATE` means metadata updated until (inclusive) `{date}`.
* `FROM_PUB_DATE` means article published since (inclusive) `{date}`, `UNTIL_PUB_DATE` published until (inclusive) `{date}`.
* `MEMBER` is the CrossRef member_id, which you find by searching the member database, e.g. `http://api.crossref.org/members?query=elife`.
   If you have ìmport: member` in `config/settings.yml`, then the rake task will use the CrossRef member_id of all publishers added via the web interface.
* `TYPE` is the type of the resource, e.g. `journal-article`, a listing of available types can be found at `http://api.crossref.org/types`.
* `SAMPLE` returns a random sample of x DOIs and can be combined with the other parameters.

For more information please see the [CrossRef API documentation](https://github.com/CrossRef/rest-api-doc/blob/master/funder_kpi_api.md).

To load for example all eLife content created or updated in 2014 (assuming eLife was added as a publisher), use the following command:

```sh
bundle exec rake db:articles:import FROM_UPDATE_DATE=2014 UNTIL_UPDATE_DATE=2014-12
```

Bulk-load a file consisting of DOIs, one per line. It'll ignore (but count) invalid ones and those that already exist in the database:

```sh
bundle exec rake db:articles:load <DOI_DUMP
```

Format for import file

```sh
DOI Date(YYYY-MM-DD) Title
```

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

Loads 25 sample articles

```sh
bundle exec rake db:articles:seed
```

Deletes all articles and associated rows in the retrieval_statuses table. For safety reasons doesn't work in the production environment (use the following rake task).

```sh
bundle exec rake db:articles:delete_all
```

Bulk-load a file consisting of DOIs, one per line. It'll ignore (but count) invalid DOIs, and will delete all articles with matching DOIs:

```sh
bundle exec rake db:articles:delete <DOI_DUMP
```

Format for import file:

```sh
DOI Date(YYYY-MM-DD) Title
```

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

Removes all HTML and XML tags from title field (for legacy data).

```sh
bundle exec rake db:articles:sanitize_title
```

Isnstall sources. Provide one or more source names as arguments, e.g. `rake db:sources:install[pmc]` or install all available sources without arguments:

```sh
bundle exec rake db:sources:install
```

Uninstall sources. Provide one or more source names as arguments, e.g. `rake db:sources:uninstall[pmc]`:

```sh
bundle exec rake db:sources:uninstall
```

Deletes all resolved alerts:

```sh
bundle exec rake db:alerts:delete
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

### queue.rake

Queue all articles

```sh
bundle exec rake queue:all
```

Queue article with given DOI:

```sh
bundle exec rake queue:one[DOI]
```

Start job queue

```sh
bundle exec rake queue:start
```

Stop job queue

```sh
bundle exec rake queue:stop
```

By default the rake tasks above run for all sources. Do have them run for one or more specific sources, add the source names as parameters:

```sh
bundle exec rake queue:all[mendeley,citeulike]
```

### pmc.rake

Import latest (i.e. last month's) PubMed Central usage stats.

```sh
bundle exec rake pmc:update
```

Import all PubMed Central usage stats since month/year.

```sh
bundle exec rake pmc:update MONTH=1 YEAR=2013
```

### report.rake

Generate all article stats reports.

```sh
bundle exec rake report:all_stats
```

Generate CSV file with ALM stats for private and public sources.

```sh
bundle exec rake report:alm_private_stats
```

Generate CSV file with ALM stats for public sources.

```sh
bundle exec rake report:alm_stats
```

Generate CSV file with combined ALM private and public sources.

```sh
bundle exec rake report:combined_private_stats
```

Generate CSV file with combined ALM stats.

```sh
bundle exec rake report:combined_stats
```

Generate CSV file with Counter usage stats.

```sh
bundle exec rake report:counter
```

Generate CSV file with Counter combined usage stats.

```sh
bundle exec rake report:counter_combined_stats
```

Generate CSV file with Counter HTML usage stats.

```sh
bundle exec rake report:counter_html_stats
```

Generate CSV file with Counter PDF usage stats.

```sh
bundle exec rake report:counter_pdf_stats
```

Generate CSV file with cumulative Counter usage stats.

```sh
bundle exec rake report:counter_stats
```

Generate CSV file with Counter XML usage stats.

```sh
bundle exec rake report:counter_xml_stats
```

Generate CSV file with Mendeley stats.

```sh
bundle exec rake report:mendeley_stats
```

Generate CSV file with PMC usage stats.

```sh
bundle exec rake report:pmc
```

Generate CSV file with PMC combined usage stats.

```sh
bundle exec rake report:pmc_combined_stats
```

Generate CSV file with PMC HTML usage stats over time.

```sh
bundle exec rake report:pmc_html_stats
```

Generate CSV file with PMC PDF usage stats over time.

```sh
bundle exec rake report:pmc_pdf_stats
```

Generate CSV file with PMC cumulative usage stats.

```sh
bundle exec rake report:pmc_stats
```

Zip reports.

```sh
bundle exec rake report:zip
```

### workers.rake

Start all the workers.

```sh
bundle exec rake workers:start_all
```

Stop all the workers.

```sh
bundle exec rake workers:stop_all
```

### filter.rake

Create alerts by filtering API responses

```sh
bundle exec rake filter:all
```

Unresolve all alerts that have been filtered (e.g. to re-run filters with new settings)

```sh
bundle exec rake filter:unresolve
```

### mailer.rake

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
