There are several ALM-specific rake tasks that help with administration of the ALM application.

### db.rake

    rake db:articles:load <DOI_DUMP

Bulk-load a file consisting of DOIs, one per line. it'll ignore (but count) invalid ones and those that already exist in the database.

Format for import file: 

    DOI Date(YYYY-MM-DD) Title

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

    rake db:articles:seed

Loads 25 sample articles.

    rake db:articles:delete

Deletes all articles and associated rows in retrieval_statuses and retrieval_histories. For safety reasons doesn't work in the production environment.
    
### doi_import.rake

    rake doi_import <DOI_DUMP

Alias to `rake db:articles:load`, see above.

### queue.rake

    rake queue:SOURCE

Queue all articles for the given source.

    rake queue:single_job[DOI,SOURCE]

Queue job for given DOI and SOURCE.

    rake queue:all_jobs[SOURCE]

Queue all jobs for given SOURCE.

### workers.rake

    rake workers:start_all

Start all the workers.

    rake workers:stop_all

Stop all the workers.

    rake workers:add_to_source [SOURCE=name]

Add one worker to a given source queue.

    rake workers:start_source [SOURCE=name]

Start all the workers for a given source queue.

    rake workers:stop_source [SOURCE=name]

Stop workers for a given source queue.

    rake workers:monitor

Monitor workers: check every two hours that workers are still running.