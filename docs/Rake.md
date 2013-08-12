There are several ALM-specific rake tasks that help with administration of the ALM application. They can be listed with the following command:

    rake -T

Depending on your server setup you may have to use `bundle exec rake` instead of `rake`.

### db.rake

Bulk-load a file consisting of DOIs, one per line. it'll ignore (but count) invalid ones and those that already exist in the database:

    rake db:articles:load <DOI_DUMP

Format for import file:

    DOI Date(YYYY-MM-DD) Title

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

Loads 25 sample articles:

    rake db:articles:seed

Deletes all articles and associated rows in retrieval_statuses and retrieval_histories. For safety reasons doesn't work in the production environment.

    rake db:articles:delete

Deletes all resolved errors:

    rake db:error_messages:delete

Delete old API requests (only keep the last 10,000):

    rake db:api_requests:delete

### doi_import.rake

Alias to `rake db:articles:load`, see above.

    rake doi_import <DOI_DUMP

### queue.rake

Queue all articles for the given source.

    rake queue:SOURCE

Queue job for given DOI and SOURCE.

    rake queue:single_job[DOI,SOURCE]

Queue all jobs for given SOURCE.

    rake queue:all_jobs[SOURCE]

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
