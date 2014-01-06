There are several ALM-specific rake tasks that help with administration of the ALM application. They can be listed with the following command:

    rake -T

Depending on your server setup you may have to use `bundle exec rake` instead of `rake`.

### db.rake

Bulk-load a file consisting of DOIs, one per line. It'll ignore (but count) invalid ones and those that already exist in the database:

    rake db:articles:load <DOI_DUMP

Format for import file

    DOI Date(YYYY-MM-DD) Title

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

Loads 25 sample articles

    rake db:articles:seed

Deletes all articles and associated rows in retrieval_statuses and retrieval_histories. For safety reasons doesn't work in the production environment.

    rake db:articles:delete_all

Bulk-load a file consisting of DOIs, one per line. It'll ignore (but count) invalid DOIs, and will delete all articles with matching DOIs:

    rake db:articles:delete <DOI_DUMP

Format for import file:

    DOI Date(YYYY-MM-DD) Title

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

Removes all HTML and XML tags from title field (for legacy data).

    rake db:articles:sanitize_title

Isnstall sources. Provide one or more source names as arguments, e.g. `rake db:sources:install[pmc]` or install all available sources without arguments:

    rake db:sources:install

Uninstall sources. Provide one or more source names as arguments, e.g. `rake db:sources:uninstall[pmc]`:

    rake db:sources:uninstall

Deletes all resolved alerts:

    rake db:alerts:delete

Delete old API requests (only keep the last 10,000):

    rake db:api_requests:delete

Delete all resolved API responses older than 24 hours:

    rake db:api_responses:delete

The last three rake tasks should run regularly, and can be set up to run as a daily cron task with `bundle exec whenever -w`.

### doi_import.rake

Alias to `rake db:articles:load`, see above.

    rake doi_import <DOI_DUMP

### queue.rake

Queue all articles

    rake queue:all

Queue article with given DOI:

    rake queue:one[DOI]

Start job queue

    rake queue:start

Stop job queue

    rake queue:stop

By default the rake tasks above run for all sources. Do have them run for one or more specific sources, add the source names as parameters:

    rake queue:all[mendeley,citeulike]

### pmc.rake

Import latest PubMed Central usage stats.

    rake pmc:update

Import all PubMed Central usage stats since month/year.

    rake pmc:update[month,year]

### workers.rake

Start all the workers.

    rake workers:start_all

Stop all the workers.

    rake workers:stop_all

Add one worker to a given source queue.

    rake workers:add_to_source [SOURCE=name]

Start all the workers for a given source queue.

    rake workers:start_source [SOURCE=name]

Stop workers for a given source queue.

    rake workers:stop_source [SOURCE=name]

Monitor workers: check every two hours that workers are still running.

    rake workers:monitor

### filter.rake

Create alerts by filtering API responses

    rake filter:all

Unresolve all alerts that have been filtered (e.g. to re-run filters with new settings)

    rake filter:unresolve

### mailer.rake

Send all reports

    rake mailer:all

Send error report

    rake mailer:error_report

Send status report

    rake mailer:status_report
