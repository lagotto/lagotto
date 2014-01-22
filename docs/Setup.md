Nine sources are preconfigured, 5 of them are not activated because you have to first supply passwords or API keys for them. CiteULike, PubMed Central Citations, Wikipedia and ScienceSeeker can be used without further configuration. Thirty sample articles from PLOS and Copernicus are provided, and can be seeded with `rake db:articles:seed`.

Groups and sources are already configured if you installed via Chef/Vagrant, or if you issued the `rake db:setup` command. You can also add groups and sources later with `rake db:seed`.

The admin user can be created when using the web interface for the first time. After logging in as admin you can add articles and configure sources.

All rake tasks are issued from the application root folder. `RAILS_ENV=production` should be appended to the rake command when running in production.

### Configuring sources

The following configuration options for sources are available via the web interface:

* whether the source is queueing jobs (default true)
* whether the results can be shared via the API (default true)
* number of workers for the job queue (default 1)
* job_batch_size: number of articles per job (default 200)
* batch_time_interval (default 1 hour)
* staleness: update interval depending on article publication date (default daily the first 31 days, then 4 times a month up until one year, then monthly)
* rate-limiting (default 10,000 or no rate-limiting)
* timeout (default 30 sec)
* maximum number of failed queries allowed before being disabled (default 200)
* maximum number of failed queries allowed in a time interval (default 86400 sec)
* disable delay after too many failed queries (default 10 sec)

Through these setup options the behavior of sources can be fine-tuned, but the default settings should almost always work. Rate-limiting is currently only implemented for the Nature Blogs source. Please contact us if you have any questions.

### Adding users

The ALM application can be configured to use [Mozilla Persona](http://www.mozilla.org/en-US/persona/) to add additional users. To use Persona, make sure `config/settings.yml` contains `persona: true`, the default setting. No other configuration is necessary.

The ALM application supports the following roles:

* API user - only API key
* staff - read-only access to admin area
* admin - full access to admin area

The API key is shown in the account profile, use `&api_key=[API_KEY]` in all API requests.

### Precompile assets
Assets (CSS, Javascripts, images) need to be precompiled when running Rails in the `production` environment (but not in `development`). Run the following rake task, then restart the server:

```sh
bundle exec rake assets:precompile RAILS_ENV=production
```

### Seeding articles

A set of 25 sample articles is loaded during installation when using Vagrant and `seed_sample_articles` in `node.json`is set to `true`. They can also be seeded later via rake task:

```sh
rake db:articles:seed
```

### Adding articles

Articles can be added via the web interface (after logging in as admin), or via the command line:

```sh
rake db:articles:load <DOI_DUMP
```

The command `rake doi_import <DOI_DUMP` is an alias. This bulk-loads a file consisting of DOIs, one per line. It'll ignore (but count) invalid ones and those that already exist in the database.

Format for import file:

```sh
DOI Date(YYYY-MM-DD) Title
```

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

### Deleting articles

Articles can be deleted via the web interface (after logging in as admin), or via the command line:

```sh
rake db:articles:delete
```

This rake task deletes all articles. For security reasons this rake task doesn't work in the production environment.

### Adding metrics in development

Metrics are added by calling external APIs in the background, using the [delayed_job](https://github.com/collectiveidea/delayed_job) queuing system. The results are stored in CouchDB. When we have to update the metrics for an article (determined by the staleness interval), a job is added to the background queue for that source. A delayed_job worker will then process this job in the background. We need to run at least one delayed_job to do this.

In development mode this is done with `foreman`, using the configuration in `Procfile`:

```sh
foreman start
```

To stop all background processing, kill foreman with `ctrl-c`.

### Adding metrics in production

In production mode the background processes run via the `upstart`system utility. The upstart scripts can be created using foreman (where USER is the user running the web server). To have foreman detect the production environment, create a file `.env` in the root folder of your application with the content

```sh
RAILS_ENV=production
```

This file is created automatically if you use Vagrant. Use the path to the Rails log folder and the username of the user running the application:

```sh
sudo foreman export upstart /etc/init -l /PATH_TO_LOG_FOLDER/log -u USER -c worker=3
```

This command creates three upstart scripts that will run in parallel. The number of workers you will need depends on the number of articles (and sources) and the available RAM on your server, a rough estimate is one worker per 5,000-10,000 articles.

The background processes can then be started or stopped using Upstart:

```sh
sudo start alm
sudo stop alm
```

Foreman also supports bluepill, inittab and runit, read the [man page](http://ddollar.github.io/foreman/) for more information.