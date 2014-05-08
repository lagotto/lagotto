---
layout: page
title: "Releases"
---

## [ALM 3.0](https://github.com/articlemetrics/alm/releases/tag/v.3.0)

ALM 3.0 was released on May 8, 2014 with the following features:

* rewrite of all sources
* rewrite of backend processing of source API responses
* daily and monthly visualizations for all sources
* standardized events in CSL format
* Rails 3.2.18

## [ALM 2.14](https://github.com/articlemetrics/alm/releases/tag/v.2.14)

ALM 2.14 was released on April 24, 2014 with the following new features:

* extensive refactoring of background workers for sources
* fixed some open issues with displaying information using the d3.js library (and included Jasmine Javascript unit tests)
* full support for using the pmid or pmcid instead of the doi as required persistent identifier for every article
* improved support for Capistrano 3
* many bug fixes

## [ALM 2.13.2](https://github.com/articlemetrics/alm/releases/tag/v.2.13.2)

ALM 2.13.2 was released on March 27, 2014 with a focus on bug fixes:

* OAuth2 authentication for Mendeley
* switch to Scopus REST API (from SOAP)
* partial publication dates (year or year-month)
* limit number of active workers per source
* better monitoring of background workers and jobs
* Rails 3.2.17

#### Upgrade

Migrate to new date format (year, month, day):

```sh
bundle exec rake db:articles:date_parts RAILS_ENV=production
```

Add number of workers in `config/settings.yml`:

```yaml
defaults: &defaults
  workers: 3
```

Update Mendeley configuration (after getting `client ID` and `secret` from Mendeley):

```sh
Url
https://api-oauth2.mendeley.com/oapi/documents/details/%{id}

Url with type
https://api-oauth2.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}

Url with title
https://api-oauth2.mendeley.com/oapi/documents/search/%{title}/?items=10

Authentication url
https://api-oauth2.mendeley.com/oauth/token

Related articles url
https://api-oauth2.mendeley.com/oapi/documents/related/%{id}

Client id
EXAMPLE

Secret
EXAMPLE
```

Add Scopus source (after getting `api_key` and `insttoken` from Scopus):

```sh
api_key
EXAMPLE

insttoken
EXAMPLE
```

## [ALM 2.12.1](https://github.com/articlemetrics/alm/releases/tag/v.2.12.1)

ALM 2.12.1 was released on February 10, 2014 with the following changes:

* hotfix for Facebook source
* added Postgres support (with big help from @CottageLabs)
* queue articles by publication date
* changed how we get the canonical URL for a DOI
* updated documentation, in particular how we setup ALM

#### Upgrade

Update Facebook configuration:

```sh
URL
https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'
```

## [ALM 2.11.2](https://github.com/articlemetrics/alm/releases/tag/v.2.11.2)

ALM 2.11.2 was released on January 22, 2014. Changes in this release include:

* sources, status and api_requests in the admin dashboard are loaded via cached API requests for better performance
* included performance improvements from @CottageLabs, in particular additional MySQL indexes
* included ALM visualization code from @jalperin
* upgraded to Bootstrap 3, many small visual changes in the frontend
* added Twitter source
* added monthly CSV report that is automatically generated
* fixed bug that could cause wrong login credentials

#### Upgrade

Update CouchDB design docs (needed for reports):

```sh
curl -X PUT -d @design-doc/reports.json 'http://localhost:5984/alm/_design/reports'
```

Remove HTML and XML from article titles:

```sh
bundle exec db:articles:sanitize_title
```

## [ALM 2.10.1](https://github.com/articlemetrics/alm/releases/tag/v.2.10.1)

ALM 2.10.1 was released on November 13, 2013 with the following features:

* improve dashboard performance
* improve reporting
* merged DOI import code from CrossRef

## [ALM 2.9.15](https://github.com/articlemetrics/alm/releases/tag/v.2.9.15)

ALM 2.9.15 was released on November 3, 2013. This release contains fixes for the mailer functionality and two new reports:

* status report
* disabled source report

A new source has been added:

* DataCite

## [ALM 2.9.7](https://github.com/articlemetrics/alm/releases/tag/v.2.9.7)

ALM 2.9.7 was released on October 3, 2013. This release fixes many small bugs of the 2.9 release and adds the following new sources:

* PMC Europe Citations
* PMC Europe Database Links
* Reddit
* Wordpress.com
* OpenEdition

## [ALM 2.9](https://github.com/articlemetrics/alm/releases/tag/v.2.9)

ALM 2.9 was released on September 16, 2013. This version contains numerous bug fixes, and some important parts of the application were refactored

* all HTTP calls to external APIs now use the Faraday library, with automatic JSON decoding and central error logging
* the duration of responses from external APIs is now logged and displayed
* XML parsing was cleaned up and consolidated into the nokogiri gem
* background processing has been simplified
* the automatic installation with Vagrant was improved and the documentation updated

The major new feature in this release is error tracking via filters. Filters can easily be added and customized, and they will generate a daily error report that is sent out via email

## [ALM 2.8](https://github.com/articlemetrics/alm/releases/tag/v.2.8)

ALM 2.8 was released on July 22, 2013. The development work focused on user account management.

## User accounts

Prior to this release, the ALM application allowed only a single user account. We can now have multiple user accounts, plus different roles for them:

* API user - to obtain an API key
* staff - read-only access to the admin dashboard
* admin - full access to the admin dashboard

A new user admin dashboard facilitates user management.

### Social login

To facilitate account management for users and ALM admins, new user accounts can only be created via social login with one of these services:

* [Github OAuth](http://developer.github.com/v3/oauth/)
* [Mozilla Persona](http://www.mozilla.org/en-US/persona/)

The ALM application can be configured to use one of these services (but not both), or to use the old system of only a single admin user. The documentation has been updated to reflect these changes.

### API keys

Now that API keys are created within the ALM application, we can check for valid API keys in every API request. This is currently only done to allow access to private sources for admins, and to enable create/update/delete in the REST API. For security reasons create/update/delete only works from requests originating from the same computer.

## Documentation

The documentation in the wiki is now included in the application, making it easier for users to find documentation. We use the [github-markdown gem](http://rubygems.org/gems/github-markdown) for this. The documentation has been updated with the changes in ALM 2.8, and other updates.

## Other Changes

Many small changes and bug fixes. We now use memcached for caching, and we added to cron jobs to clean up temporary tables (error_messages and api_requests).

## [ALM 2.7](https://github.com/articlemetrics/alm/releases/tag/v.2.7)

ALM 2.7 was released on May 16, 2013. The development work focused on adding Javascript libraries that talk to the ALM API and can be embedded in other web sites.

### Javascript single article visualizations

We added visualizations for single articles using the d3.js library, including time-based visualizations by day, month and year. We have created a new [Github repository](https://github.com/articlemetrics/almviz) that will hold all future work on Javascript libraries talking to the ALM API. To make these visualizations easier we made two changes to the [v3 ALM API](API):

* added signposts (views, shares, bookmarks, citations) as summary information
* added metrics by day, month and year for every source

### Other Changes

We have made it easier to install the ALM application by adding and testing support for Amazon AWS via Vagrant. We added rake tasks to seed or delete articles, and to delete resolved errors and old API requests. Many small bugs were fixed and the ALM application was updated to use the latest Rails version (3.2.13).

## [ALM 2.6](https://github.com/articlemetrics/alm/releases/tag/v.2.6)

ALM 2.6 was released on March 19, 2013. The development work focused on two areas: API performance and easy installation.

### API Performance

The API code was refactored, adding the [Draper Decorator](https://github.com/drapergem/draper) between the model and the [RABL Views](https://github.com/nesquena/rabl). We added caching, using Russian Doll fragment caching as described [here](http://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works). It required some extra work to make this work with RABL and Draper. We also added a visualization of API requests to the admin dashboard, using d3.js and the [crossfiler](http://square.github.com/crossfilter/) library.

### Easy Installation

To make it easier to install the ALM application, we have updated and throughoutly tested the [manual installation](installation) instructions, updated the Chef / Vagrant automated installation (now using Ubuntu 12.04 and linking directly to the Chef Cookbook repository), and provided a VMware image of ALM application (535 MB [download](http://dl.dropbox.com/u/9406373/alm_ubuntu_12.04_vmware.tar.gz), username/password: alm). The VMware image file is still experimental and feedback is appreciated.

An updated version of [Vagrant](http://docs.vagrantup.com/v2/getting-started/index.html) (1.1) was released days after ALM 2.6, and this version now supports VMware and AWS. We will support these platforms in a future ALM release to again make it easier to test or install the ALM application.

### Other Changes

This release includes many small fixes and improvements. Of particular interest are the RSS feeds for the most popular articles by source, published in the last 7 days, 30 days, 12 months, or all-time. The RSS feeds are link from the most-cited lists for each source, e.g. [here](http://alm.plos.org/sources/twitter).

## [ALM 2.5](https://github.com/articlemetrics/alm/releases/tag/v.2.5)

ALM 2.5 was released on February 1st, 2013.

* admin dashboard
* First visualizations based on d3.js
* RSS feeds
* Rails 3.2.11

## [ALM 2.4](https://github.com/articlemetrics/alm/releases/tag/v.2.4)

ALM 2.4 was released on December 20, 2012.

In this release we added a new source ([ScienceSeeker](http://scienceseeker.org/), a blog aggregator), fix many errors with sources and added tests for background and Rake tasks.

## [ALM 2.3](https://github.com/articlemetrics/alm/releases/tag/v.2.3)

ALM 2.3 was released on October 30, 2012.

* updated API (v3)

## [ALM 2.2](https://github.com/articlemetrics/alm/releases/tag/v.2.2)

ALM 2.2 was released on October 5, 2012.

* added Twitter Bootstrap CSS framework
* many small bug fixes and tweaks
* Rails 3.2.8

## [ALM 2.1](https://github.com/articlemetrics/alm/releases/tag/v.2.1)

ALM 2.1 was released on September 13, 2012.

* moved source code to Github
* added Rspec and Cucumber test coverage
* added installation script using Vagrant and Chef
* added Wikipedia source
* Rails 3.2.7

## [ALM 2.0](https://github.com/articlemetrics/alm/releases/tag/v.2.0)

ALM 2.0 was released on July 31, 2012.

* Ruby 1.9.3 and Rails 3.2.3
* switched from workling/starling to delayed_job for workers
* major refactoring of background processes
* store source data in CouchDB
