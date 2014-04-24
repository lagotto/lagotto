---
layout: page
title: "Rake"
---

There are several ALM-specific rake tasks that help with administration of the ALM application. They can be listed with the following command:

```sh
rake -T
```

Depending on your server setup you may have to use `bundle exec rake` instead of `rake`.

### db.rake

Bulk-load a file consisting of DOIs, one per line. It'll ignore (but count) invalid ones and those that already exist in the database:

```sh
rake db:articles:load <DOI_DUMP
```

Format for import file

```sh
DOI Date(YYYY-MM-DD) Title
```

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

Loads 25 sample articles

```sh
rake db:articles:seed
```

Deletes all articles and associated rows in retrieval_statuses and retrieval_histories. For safety reasons doesn't work in the production environment.

```sh
rake db:articles:delete_all
```

Bulk-load a file consisting of DOIs, one per line. It'll ignore (but count) invalid DOIs, and will delete all articles with matching DOIs:

```sh
rake db:articles:delete <DOI_DUMP
```

Format for import file:

```sh
DOI Date(YYYY-MM-DD) Title
```

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

Removes all HTML and XML tags from title field (for legacy data).

```sh
rake db:articles:sanitize_title
```

Isnstall sources. Provide one or more source names as arguments, e.g. `rake db:sources:install[pmc]` or install all available sources without arguments:

```sh
rake db:sources:install
```

Uninstall sources. Provide one or more source names as arguments, e.g. `rake db:sources:uninstall[pmc]`:

```sh
rake db:sources:uninstall
```

Deletes all resolved alerts:

```sh
rake db:alerts:delete
```

Delete old API requests (only keep the last 10,000):

```sh
rake db:api_requests:delete
```

Delete all resolved API responses older than 24 hours:

```sh
rake db:api_responses:delete
```

The last three rake tasks should run regularly, and can be set up to run as a daily cron task with `bundle exec whenever -w`.

### queue.rake

Queue all articles

```sh
rake queue:all
```

Queue article with given DOI:

```sh
rake queue:one[DOI]
```

Start job queue

```sh
rake queue:start
```

Stop job queue

```sh
rake queue:stop
```

By default the rake tasks above run for all sources. Do have them run for one or more specific sources, add the source names as parameters:

```sh
rake queue:all[mendeley,citeulike]
```

### pmc.rake

Import latest (i.e. last month's) PubMed Central usage stats.

```sh
rake pmc:update
```

Import all PubMed Central usage stats since month/year.

```sh
rake pmc:update MONTH=1 YEAR=2013
```

### workers.rake

Start all the workers.

```sh
rake workers:start_all
```

Stop all the workers.

```sh
rake workers:stop_all
```

### filter.rake

Create alerts by filtering API responses

```sh
rake filter:all
```

Unresolve all alerts that have been filtered (e.g. to re-run filters with new settings)

```sh
rake filter:unresolve
```

### mailer.rake

Send all reports

```sh
rake mailer:all
```

Send error report

```sh
rake mailer:error_report
```

Send status report

```sh
rake mailer:status_report
```
