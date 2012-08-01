Article Level Metrics (ALM), is a Ruby on Rails application started by the [Public Library of Science (PLoS)](http://www.plos.org/). It stores and reports user configurable performance data on research articles. Examples of possible metrics are online usage, citations, social bookmarks, notes, comments, ratings and blog coverage.

For more information on how PLoS uses Article-Level Metrics, see [http://article-level-metrics.plos.org/](http://article-level-metrics.plos.org/).

Version 2.0 of the application was released in July 2012 and has been updated to be compatible with Ruby 1.9.3, Rails 3.2.x, and to store the results of external API calls in CouchDB. The backend processes have been completely rewritten and now uses **delayed_job**.

## Installation

ALM is a standard Ruby on Rails application with the following requirements:

* Ruby 1.9.3
* CouchDB 1.1

CouchDB is used to store the responses from external API calls, MySQL is used for everything else. The application has been tested with Apache/Passenger, but should also run in other deployment environments, e.g. Nginx/Unicorn or WEBrick. ALM uses Ruby on Rails 3.2.3.

Don't forget to add this to the Apache virtual host file in order to keep Apache from messing up encoded embedded slashes in DOIs:

    AllowEncodedSlashes On

The delayed_job background processes are started with

    bundle exec rake workers:start_all

### Using a Platform as a Service (PaaS) provider
The ALM application can be installed has a hosted solution with a PaaS provider. This is the quickest strategy to get the application up and running.

* [Heroku](http://www.heroku.com)
* [OpenShift](https://openshift.redhat.com/app/)

Several providers provide hosting for CouchDB, including [Cloudant](https://cloudant.com).

### Using Vagrant/Chef
This is the preferred way to install the ALM application as a developer. The application will automatically be installed in a self-contained virtual machine. Download and install [**Virtualbox**][virtualbox] and [**Vagrant**][vagrant]. Then install the application with:
    
    git clone git://github.com/articlemetrics/alm.git alm
    cd alm
    vagrant up
      
[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[vagrant]: http://downloads.vagrantup.com/

After installation is finished (this can take up to 10 min on the first run) you can access the ALM application with your web browser at

    http://localhost:8080
## Usage

### API
RESTful API URLs generally correspond to HTML URLs; you can usually just add ".xml" or ".json" to the HTML (unsuffixed) URL and perform a GET request. Both XML and JSON formats are provided (CSV is also supported for the article index), though attribute arrangement might be different between formats (and might differ from the information included in the HTML presentation generated without the format suffix).

All ".json" requests can be made with JSONP support by including a querystring "callback" parameter; the result will be wrapped in a Javascript function call to that parameter's value, for ease of handling on the client side. For example:

`/articles/10.1371/bogus.json` would return something like this:

    {"article": {"doi": "10.1371/bogus", "pub_med": null, "pub_med_central": null, "updated_at": "2009-01-04T13:59:27-08:00", 
    "citations_count": 0}}

### Rake

The ALM application includes several rake tasks for system maintenance.

#### doi_import.rake

    rake doi_import <DOI_DUMP

Bulk-load a file consisting of DOIs, one per line. it'll ignore (but count) invalid ones and those that already exist in the database.

Format for import file: 

    DOI Date(YYYY-MM-DD) Title

doi_import splits on white space for the first two elements, and then takes the rest of the line (title) as one element including any whitespace in the title.

#### queue.rake

    rake queue::SOURCE
    
Queue background jobs for the specified source.
   
    rake queue:single_job, [SOURCE, SOURCE]

Queue a background job for the specified DOI and source.

#### workers.rake

    rake workers:start_all
    rake workers:stop_all
    rake workers:start_source SOURCE
    rake workers:stop_source SOURCE
    
Start or stop all workers, or all workers for a specified source.

    rake workers:add_to_source SOURCE
    
Add another worker to a given source queue.

    rake workers:monitor
    
Monitor workers. Check every two hours and restart them if necessary.

## More Documentation
[https://github.com/articlemetrics/alm/wiki][documentation]

[documentation]: https://github.com/articlemetrics/alm/wiki

## Follow @plosalm on Twitter
You should follow [@plosalm][follow] on Twitter for announcements and updates about
this application.

[follow]: https://twitter.com/plosalm

## Mailing List
Please direct questions about the library to the [mailing list].

[mailing list]: https://groups.google.com/group/plos-api-developers

## Apps Wiki
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