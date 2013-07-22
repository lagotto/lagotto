Nine sources are preconfigured, 5 of them are not activated because you have to first supply passwords or API keys for them. CiteULike, PubMed Central Citations, Wikipedia and ScienceSeeker can be used without further configuration. Twenty-five sample articles from PLOS and Copernicus are provided, and can be seeded with `rake db:articles:seed`.

Groups and sources are already configured if you installed via Chef/Vagrant, or if you issued the `rake db:setup` command. You can also add groups and sources later with `rake db:seed`. 

The admin user can be created when using the web interface for the first time. After logging in as admin you can add articles and configure sources.

The following configuration options for sources are stored in `source_configs.yml`:

* job_batch_size: number of articles per job (default 200)
* staleness: refresh interval (default 7 days)
* batch_time_interval (default 1 hour) 
* requests_per_day (default nil) 

The following configuration options for sources are available via the web interface:

* timeout (default 30 sec)
* disable delay (default 10 sec)
* number of workers for the job queue (default 1)
* whether the results can be shared via the API (default true)
* maximum number of failed queries allowed before being disabled (default 200)
* maximum number of failed queries allowed in a time interval (default 86400 sec)

Through these setup options the behavior of sources can be fine-tuned. Please contact us if you have any questions.

All rake tasks are issued from the application root folder. `RAILS_ENV=production` should be appended to the rake command when running in production.

### Adding users

The ALM application can be configured to use [Mozilla Persona](http://www.mozilla.org/en-US/persona/) or [Github OAuth](http://developer.github.com/v3/oauth/) to add additional users. The ALM application supports the following roles:

* API user - only API key
* staff - read-only access to admin area
* admin - full access to admin area

The API key is shown in the account profile, use `&api_key=[API_KEY]` in all API requests.

#### Github OAuth

To use Github OAuth, login into your Github account and register your ALM application at https://github.com/settings/applications (under Developer applications). Provide the name and URL to your application, which you can also use for the callback parameter (no need to include the callback path `/auth/github/callback`). Then copy the `Client ID` and `Cleint Secret` into `config/settings.yml`:

    github_client_id: xxx
    github_client_secret: xxx

We are using the default scope, which only reads public information and can't write to the Github account.

#### Persona

To use Persona, make sure Github is disabled and `config/settings.yml` contains `persona: true`. No other configuration is necessary.

### Seeding articles

A set of 25 sample articles is loaded during installation when using Vagrant and `seed_sample_articles` in `node.json`is set to `true`. They can also be seeded later via rake task:

    rake db:articles:seed
    
### Adding articles

Articles can be added via the web interface (after logging in as admin), or via the command line:

    rake db:articles:load <DOI_DUMP

The command `rake doi_import <DOI_DUMP` is an alias. This bulk-loads a file consisting of DOIs, one per line. It'll ignore (but count) invalid ones and those that already exist in the database.

Format for import file: 

    DOI Date(YYYY-MM-DD) Title

The rake task splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

### Deleting articles

Articles can be deleted via the web interface (after logging in as admin), or via the command line:

    rake db:articles:delete

This rake task deletes all articles. For security reasons this rake task doesn't work in the production environment.
    
### Adding metrics in development

Metrics are added by calling external APIs in the background, using the [delayed_job](https://github.com/collectiveidea/delayed_job) queuing system. The results are stored in CouchDB. When we have to update the metrics for an article (determined by the staleness interval), a job is added to the background queue for that source. A delayed_job worker will then process this job in the background. We have to set up a queue and at least one worker for every source. 

In development mode this is done with `foreman`, using the configuration in `Procfile`:
    
    foreman start
    
To stop all background processing, kill foreman with `ctrl-c`.
    
### Adding metrics in production
    
In production mode the background processes run via the `upstart`system utility. The upstart scripts can be created using foreman (where USER is the user running the web server) via

    sudo foreman export upstart /etc/init -a alm -f Procfile.prod -l /USER/log -u USER
    
This command creates two upstart scripts for each source (one worker and one queuing script). For servers with less than 1 GB of memory we can run the background processes with only two scripts via

    sudo foreman export upstart /etc/init -a alm -f Procfile.staging -l /USER/log -u USER

The background processes can then be started or stopped using Upstart:

    sudo start alm
    sudo stop alm