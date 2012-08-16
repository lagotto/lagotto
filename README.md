Article Level Metrics (ALM), is a Ruby on Rails application started by the [Public Library of Science (PLoS)](http://www.plos.org/). It stores and reports user configurable performance data on research articles. Examples of possible metrics are online usage, citations, social bookmarks, notes, comments, ratings and blog coverage.

For more information on how PLoS uses Article-Level Metrics, see [http://article-level-metrics.plos.org/](http://article-level-metrics.plos.org/).

Version 2.0 of the application was released in July 2012 and has been updated to be compatible with Ruby 1.9.3, Rails 3.2.x, and to store the results of external API calls in CouchDB. The backend processes have been completely rewritten and now uses **delayed_job**.

## Installation

ALM is a standard Ruby on Rails application with the following requirements:

* Ruby 1.9.3
* CouchDB 1.1

CouchDB is used to store the responses from external API calls, MySQL is used for everything else. The application has been tested with Apache/Passenger, but should also run in other deployment environments, e.g. Nginx/Unicorn or WEBrick. ALM uses Ruby on Rails 3.2.3.

In a manual installation the following configuration files have to be created using the examples provided:

* config/database.yml
* config/settings.yml

Don't forget to set up the CouchDB URL in `settings.yml` and include username and password if necessary. Also don't forget to add this to the Apache virtual host file in order to keep Apache from messing up encoded embedded slashes in DOIs:

    AllowEncodedSlashes On

### Using Vagrant/Chef
This is the preferred way to install the ALM application as a developer. The application will automatically be installed in a self-contained virtual machine. Download and install [**Virtualbox**][virtualbox] and [**Vagrant**][vagrant]. Then install the application with:
    
    git clone git://github.com/articlemetrics/alm.git alm
    cd alm
    # (Optional) Enter usernames, passwords and API keys for external sources in dna.json
    vagrant up
      
[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[vagrant]: http://downloads.vagrantup.com/

If there is an error during installation, you can re-run the installation script with `vagrant provision`. After installation is finished (this can take up to 10 min on the first run) you can access the ALM application with your web browser at

    http://localhost:8080
	
The Rails application runs in Development mode. The database servers are made available at ports 3307 (MySQL) and 5985 (CouchDB). For SSH use command `vagrant ssh`, the application root is at `/vagrant`. The MySQL password is randomly generated and is stored at `config/database.yml`. Seven sources are preconfigured, 5 of them are not activated because you have to first supply passwords or API keys for them. CiteULike and PubMed Central Citations can be used without further configuration. Ten sample articles from PLOS are provided.

### Using a Platform as a Service (PaaS) provider
The ALM application can be installed as a hosted solution with a PaaS provider. 

* [Heroku](http://www.heroku.com)
* [OpenShift](https://openshift.redhat.com/app/)

Several providers provide hosting for CouchDB, including [Cloudant](https://cloudant.com).

## Usage

### Setup

Groups and sources are already configured if you installed via Chef/Vagrant, or if you issued the `rake db:setup` command. You can also add groups and sources later with `rake db:seed`. 

The admin user can be created when using the web interface for the first time. After logging in as admin you can add articles and configure sources.

The following configuration options for sources are stored in `settings.yml`:

* job_batch_size: number of articles per job (default 200)
* max_job_batch_size: maximal number of articles per job (default 1000)
* default_job_batch_size: number of articles per job (default 202)
* staleness: refresh interval (default 7 days)
* batch_time_interval (default 1 hour) 

The following configuration options for sources are available via the web interface:

* timeout (default 30 sec)
* disable delay (default 10 sec)
* number of workers for the job queue (default 1)
* whether the results can be shared via the API (default true)
* maximum number of failed queries allowed before being disabled (default 200)
* maximum number of failed queries allowed in a time interval (default 86400 sec)

Through these setup options the behavior of sources can be fine-tuned. Please contact us if you have any questions.

### Adding articles

Articles can be added via the web interface (after logging in as admin), or via `rake doi_import <DOI_DUMP` (see below).

### Adding metrics

Metrics are automatically added in the background, using the [delayed_job](https://github.com/collectiveidea/delayed_job) queuing system. The results returned by external APIs are stored in CouchDB.

When we have to update the metrics for an article (determined by the staleness interval), a job is added to the background queue for that source. A delayed_job worker will then process this job in the background. We have to set up a queue and at least one worker for every source. In development mode this is done with `foreman`, using the configuration in `Procfile`:
    
    foreman start
    
In production mode the background processes run via the `upstart`system utility. The Chef/Vagrant setup has the upstart scripts already configured, otherwise this can be done (where USER is the user running the web server) via

    rvmsudo foreman export upstart /etc/init -a alm -l /USER/log -u USER
    
## More Documentation
In the Wiki at [https://github.com/articlemetrics/alm/wiki][documentation].
 
[documentation]: https://github.com/articlemetrics/alm/wiki
 
## Follow @plosalm on Twitter
You should follow [@plosalm][follow] on Twitter for announcements and updates.
 
[follow]: https://twitter.com/plosalm
 
## Mailing List
Please direct questions about the library to the [mailing list].
 
[mailing list]: https://groups.google.com/group/plos-api-developers
 
## List your application in the Wiki
Does your project or organization use this application? Add it to the [
FAQ][faq]!
 
[faq]: https://github.com/articlemetrics/alm/wiki/faq
 
## Note on Patches/Pull Requests
 
* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.
 
## Copyright
Copyright (c) 2009-2012 by Public Library of Science. See [LICENSE](https://github.com/articlemetrics/alm/blob/master/LICENSE.md) for details.