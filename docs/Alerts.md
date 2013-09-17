This page lists the most common errors in the error log of the ALM application.

### [SOURCE] has exceeded maximum failed queries. Disabling the source.

A source will be temporarily disabled when there are too many errors. When this happens depends on two settings in the source configuration:

- maximum number of failed queries allowed before being disabled (default 200)
- maximum number of failed queries allowed in a time interval (default 86400 sec)

### execution expired in [SOURCE]

Timeout error in a source, probably because of intermittent network problems. This can be ignored unless it happens frequently.

### execution expired (Delayed::Worker.max_run_time is only 3000 seconds) in [SOURCE]

A background job could not be processed in `max_run_time`. This typically happens when queries for individual articles took too long, depending on the following settings in the source configuration:

- job_batch_size: number of articles per job (default 200)
- timeout (default 30 sec)
- batch_time_interval (default 1 hour)

If all 200 jobs take close to 30 sec, and they will not be done within an hour, and before we process the next batch. Decrease `job_batch_size` and/or `timeout`, or increase `batch_time_interval` if you see to many of these errors for a source.

### [401] Missing API key.

The ALM application uses the ALM API for some visualizations and uses the API key of the first admin user for this. This error means that this key couldn't be found, e.g. because no admin user was set up. 

### [409] Conflict while requesting "http://localhost:5984/alm/facebook:DOI"

CouchDB can't be updated because the _rev for the document provided by the ALM application doesn't match the most recent _rev in CouchDB. 

### [503] Service Temporarily Unavailable while requesting http://blogs.nature.com/posts.json?doi=DOI

The server is overloaded or we hit rate-limiting. This is a temporary error and can be ignored unless it happens frequently.