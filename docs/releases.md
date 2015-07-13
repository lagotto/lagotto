---
layout: card_list
title: "Releases"
---

## Lagotto 4.2 (July 13, 2015)

[Lagotto 4.2](https://github.com/articlemetrics/lagotto/releases/tag/v.4.2) was released on July 13, 2015 with the following changes:

* export CSV summary report to Zenodo data repository ([#339](https://github.com/articlemetrics/lagotto/issues/339))
* process pmc import and parsing in the background ([#363](https://github.com/articlemetrics/lagotto/issues/363))
* allow wildcard searches for works in the API and admin frontend ([#368](https://github.com/articlemetrics/lagotto/issues/368))
* added missing author information to v6 API ([#370](https://github.com/articlemetrics/lagotto/issues/370))
* make sure DOIs are stored in lowercase([#372] (https://github.com/articlemetrics/lagotto/issues/372))
* optionally load all DataONE member nodes as publishers ([#374](https://github.com/articlemetrics/lagotto/issues/374))
* added methods to fetch metadata for DataCite DOIs, and to look up the DOI registration agency ([#376](https://github.com/articlemetrics/lagotto/issues/376))
* added registration agency column to works ([#377](https://github.com/articlemetrics/lagotto/issues/377))
* store temporary files in tmp folder ([#378](https://github.com/articlemetrics/lagotto/issues/378))
* fixed name inconsistencies for EuropePMC sources ([#379](https://github.com/articlemetrics/lagotto/issues/379))

The following new ENV variables must be set in the `.env` file to use the new Zenodo export functionality:
```
CREATOR=Public Library of Science
ZENODO_KEY=YOUR_KEY_HERE
ZENODO_URL=https://zenodo.org/api/
#ZENODO_URL=https://sandbox.zenodo.org/api/ for testing
SITENAMELONG="PLOS ALM"
```

A `ZENODO_KEY` can be obtained by creating a Zenodo account and then a personal access token on the profile page.

## Lagotto 4.1.1 (July 6, 2015)

[Lagotto 4.1.1](https://github.com/articlemetrics/lagotto/releases/tag/v.4.1.1) was released on July 6, 2015 with the following fixes:

* adapted CSV parsing to 4.0 data model ([#315](https://github.com/articlemetrics/lagotto/issues/315))
* fixed a bug in pmc feed parsing ([#354](https://github.com/articlemetrics/lagotto/issues/354))
* don't import PLOS issue images. ([#356](https://github.com/articlemetrics/lagotto/issues/356))

## Lagotto 4.1 (June 17, 2015)

[Lagotto 4.1](https://github.com/articlemetrics/lagotto/releases/tag/v.4.1) was released on June 17, 2015 with the following changes:

* refactored `/heartbeat` endpoint to use sinatra so that it works if the database is down ([#302](https://github.com/articlemetrics/lagotto/issues/302))
* fixed a bug in source and publisher caching ([#306](https://github.com/articlemetrics/lagotto/issues/306))
* upgraded source to use v.1.2 ORCID API ([#308](https://github.com/articlemetrics/lagotto/issues/308))
* fetch metadata from pubmed if there is a pmid but no doi ([#309](https://github.com/articlemetrics/lagotto/issues/309))
* added recommendations, similar works that are also tracked ([#310](https://github.com/articlemetrics/lagotto/issues/310))
* use CrossRef REST API for metadata of articles fetched via CrossRef CitedBy ([#312](https://github.com/articlemetrics/lagotto/issues/312))
* use CrossRef date indexed if date issued is in the future ([#314](https://github.com/articlemetrics/lagotto/issues/314))
* pass member id as integer to CrossRef REST API, fixing a CrossRef import issue ([#320](https://github.com/articlemetrics/lagotto/issues/320))
* optionally serve v3 API responses for single works as array for backward compatibility ([#321](https://github.com/articlemetrics/lagotto/issues/321))
* upgraded capistrano gem, use capistrano-passenger ([#323](https://github.com/articlemetrics/lagotto/issues/323))
* workaround to support 4-byte utf-8 characters, e.g. emojis ([#324](https://github.com/articlemetrics/lagotto/issues/324))
* allow update of works on import ([#325](https://github.com/articlemetrics/lagotto/issues/325))
* added optional Bugsnag error tracking, using two `ENV` variables ([#326](https://github.com/articlemetrics/lagotto/issues/326))
* use different path for RSS urls rather than file extension `.rss` ([#328](https://github.com/articlemetrics/lagotto/issues/328))
* handle timeout errors more gracefully ([#330](https://github.com/articlemetrics/lagotto/issues/330))
* avoid ActiveRecord connection pool issues ([#331](https://github.com/articlemetrics/lagotto/issues/331))
* automatically track metrics for works from article_coverage_curated source ([#332](https://github.com/articlemetrics/lagotto/issues/332))
* use http://doi.org instead of http://dx.doi.org for encoding DOIs as URLs ([#333](https://github.com/articlemetrics/lagotto/issues/333))
* use http URI of the primary identifier as the PID in the API ([#334](https://github.com/articlemetrics/lagotto/issues/334))
* automatically track metrics for blog posts referencing a work ([#335](https://github.com/articlemetrics/lagotto/issues/335))
* automatically track metrics for works mentioned in the body of another work, using the sources `europe_pmc_fulltext`, `plos_fulltext` and `bmc_fulltext` ([#336](https://github.com/articlemetrics/lagotto/issues/336))

This release includes numerous other small bug fixes. While the release fixes on bug fixes, new features were also introduced:

### Recommendations

A list of similar works that we also track, generated by common relations, e.g. other works tracked by Lagotto cited
by the same paper or bookmarked in the same ORCID profile. Available in the v6 API, e.g. [here](http://alm.plos.org/api/works/doi:10.1371/journal.pmed.1000097/recommendations).

### Identifiers as URIs

Starting with this release, the `id` for a work in the v6 API will always be a URL, e.g. `http://doi.org/10.1371/journal.pmed.1000097`, and the use of `dx.doi.org` has been
changed to `doi.org` in all places.

### Second-order Events

Lagotto 4.1 adds support for second-order events, i.e. it will track news items and blog posts that discuss a work in Lagotto.
We do the same for scholarly articles that mention a tracked work in the body text (where we can search the fulltext), e.g. informal citations to datasets.

## Lagotto 4.0 (May 5, 2015)

[Lagotto 4.0](https://github.com/articlemetrics/lagotto/releases/tag/v.4.0) was released on May 5, 2015 with the following changes:

* normalized responses from external sources to be stored in MySQL. CouchDB is no longer required for the core Lagotto functionality ([#213](https://github.com/articlemetrics/lagotto/issues/213))
* show more CSL information in API and admin dashboard ([#284](https://github.com/articlemetrics/lagotto/issues/284))
* started new v6 API ([#287](https://github.com/articlemetrics/lagotto/issues/287))
* show related works (references and versions) in new v6 API and admin dashboard ([#296](https://github.com/articlemetrics/lagotto/issues/296))
* added `ads` and `ads_fulltext` data sources. `ads` finds ArXiV preprints that became peer-reviewed papers, `ads_fulltext` allows fulltext search for all ArXiV preprints ([#297](https://github.com/articlemetrics/lagotto/issues/297))
* import couchdb data into mysql for 4.0 upgrade ([#301](https://github.com/articlemetrics/lagotto/issues/301))

### Upgrading

Starting with Lagotto 4.0 frontend assets are installed via [NPM](https://www.npmjs.com/) and [Bower](http://bower.io/). This is done automatically when using Chef/Vagrant. When not using Chef/Vagarant please copy `frontend/node_modules`, `frontend/bower_components`, `frontend/package.json`, `frontend/bower.json` and `frontend/.bowerrc` into `shared` and run `npm install` (not `npm -g install`) from `shared/frontend`:

```
cd /var/www/lagotto/shared/frontend
mkdir node_modules
mkdir bower_components
wget https://raw.githubusercontent.com/articlemetrics/lagotto/4-0-stable/frontend/package.json
wget https://raw.githubusercontent.com/articlemetrics/lagotto/4-0-stable/frontend/bower.json
wget https://raw.githubusercontent.com/articlemetrics/lagotto/4-0-stable/frontend/.bowerrc
npm install
```

CouchDB is no longer needed for core Lagotto functionality, but is still used to store responses from some of the sources (e.g. `F1000`).

Make sure to run the data migrations in addition to the database migrations. This happens automatically if using capistrano, otherwise run `rake data:migrate`.

After upgrading the code and running the database migrations, old monthly and daily data stored in CouchDB should be imported via:

```
bundle exec rake couchdb:import
```

Starting with the new v6 API, API versions (currently defaulting to version 6) and authentication via API key (needed for admin functionality) are provided via the HTTP header, e.g. in curl:

```
- H "Accept: application/json; version=6" -H "Authorization: Token token=API_KEY"
```

## Lagotto 3.20 (May 5, 2015)

[Lagotto 3.20](https://github.com/articlemetrics/lagotto/releases/tag/v.3.20) was released on May 5, 2015 with the following changes:

* filter authentication_token from log files ([#285](https://github.com/articlemetrics/lagotto/issues/285))
* fixed authentication error that broke creation of new user accounts ([#286](https://github.com/articlemetrics/lagotto/issues/286))
* create delete canonical_url rake task for cases where journal URLs change ([#298](https://github.com/articlemetrics/lagotto/issues/298))
* set rate-limit remaining number for all sources using memcached. This should fix rate-limiting errors with the `twitter_search` source ([#300](https://github.com/articlemetrics/lagotto/issues/300))

Make sure to run the data migrations in addition to the database migrations. This happens automatically if using capistrano, otherwise run `rake data:migrate`.

## Lagotto 3.19 (March 24, 2015)

[Lagotto 3.19](https://github.com/articlemetrics/lagotto/releases/tag/v.3.19) was released on March 24, 2015 with the following changes:

* allow user configuration of signposts, summaries of the most important metrics ([#263](https://github.com/articlemetrics/lagotto/issues/263))
* support `published_id` when creating works via the v4 API ([#264](https://github.com/articlemetrics/lagotto/issues/264))
* replacing the cucumber tests removed in ([#262](https://github.com/articlemetrics/lagotto/issues/262)) with rspec acceptance tests ([#265](https://github.com/articlemetrics/lagotto/issues/265))
* removed duplicate events in display on article pages ([#256](https://github.com/articlemetrics/lagotto/issues/256))
* hard-code configuration URLs for sources, making it easier to automatically change these parameters via an upgrade ([#271](https://github.com/articlemetrics/lagotto/issues/271))
* updated documentation to how correct service URLs for sources ([#273](https://github.com/articlemetrics/lagotto/issues/273))
* upgrade to Rails 4.2.1 ([#275](https://github.com/articlemetrics/lagotto/issues/275))
* switched from `jasmine_rails` to `teaspoon` for running javascript `jasmine` unit tests ([#276](https://github.com/articlemetrics/lagotto/issues/276))
* only create one alert per message ([#277](https://github.com/articlemetrics/lagotto/issues/277))
* fixed bug in generating report with mendeley, pmc or counter data ([#279](https://github.com/articlemetrics/lagotto/issues/279))
* added data migrations, making it easier to update data, e.g. when the database schema changes ([#280](https://github.com/articlemetrics/lagotto/issues/280))

To customize the signposts, add/uncomment the following ENV variables in your `.env` file, separating multiple sources via comma:

```sh
# customize signposts, defaults are shown
# VIEWED=pmc,counter
# SAVED=mendeley,citeulike
# DISCUSSED=twitter,twitter_search,facebook
# CITED=crossref
```

## Lagotto 3.18 (March 2, 2015)

[Lagotto 3.18](https://github.com/articlemetrics/lagotto/releases/tag/v.3.18) was released on March 2, 2015 with the following changes:

* updated europe pmc fulltext source to also search in reference lists ([#253](https://github.com/articlemetrics/lagotto/issues/253))
* added support for pagination in sources `pmc_europe`, `europe_pmc_fulltext`, and `wikipedia` sources ([#255](https://github.com/articlemetrics/lagotto/issues/255))
* added [Nature OpenSearch](http://www.nature.com/developers/documentation/api-references/opensearch-api/) source ([#257](https://github.com/articlemetrics/lagotto/issues/257))
* removed duplicate events in display on article pages ([#256](https://github.com/articlemetrics/lagotto/issues/256))
* specify mysql port in database.yml using `DB_PORT` ENV variable, defaults to `3306` ([#258](https://github.com/articlemetrics/lagotto/issues/258))
* updated documentation for API calls with many IDs, using POST instead of GET ([#259](https://github.com/articlemetrics/lagotto/issues/259))
* added live API documentation using the [swagger](http://swagger.io) framework ([#260](https://github.com/articlemetrics/lagotto/issues/260))
* removed cucumber tests, as we switched to rspec acceptance tests ([#262](https://github.com/articlemetrics/lagotto/issues/262))

The live API documentation is available at `/api`.

To load the new `nature_opensearch` source please run

```sh
RAILS_ENV=production bundle exec rake db:seed
```

## Lagotto 3.17 (February 19, 2015)

[Lagotto 3.17](https://github.com/articlemetrics/lagotto/releases/tag/v.3.17) was released on February 19, 2015 with the following changes:

* removed obsolete `dataset` parameter from Europe PMC fulltext search ([#245](https://github.com/articlemetrics/lagotto/issues/245))
* fixed issue with sidekiq paths in some configurations ([#246](https://github.com/articlemetrics/lagotto/issues/246))
* added make dependency to manual install doc ([#247](https://github.com/articlemetrics/lagotto/issues/247))
* fix in CrossRef import when no member is given ([#248](https://github.com/articlemetrics/lagotto/issues/248))
* added BMC fulltext source ([#249](https://github.com/articlemetrics/lagotto/issues/249))
* small fix in Wikipedia source ([#251](https://github.com/articlemetrics/lagotto/issues/251))
* added Bitbucket source ([#252](https://github.com/articlemetrics/lagotto/issues/252))

To load the new sources please run

```sh
RAILS_ENV=production bundle exec rake db:seed
```

## Lagotto 3.16 (February 8, 2015)

[Lagotto 3.16](https://github.com/articlemetrics/lagotto/releases/tag/v.3.16) was released on February 8, 2015 with the following changes:

* added CSS style guide ([#240](https://github.com/articlemetrics/lagotto/issues/240))
* switched from glyphicons to font-awesome as icon font ([#241](https://github.com/articlemetrics/lagotto/issues/241))
* correctly show number of new works per day on status page ([#242](https://github.com/articlemetrics/lagotto/issues/242))

The style guide is available at `/docs/styleguide`.

## Lagotto 3.15 (February 4, 2015)

[Lagotto 3.15](https://github.com/articlemetrics/lagotto/releases/tag/v.3.15) was released on February 4, 2015 with the following changes:

* added sidekiq capistrano tasks ([#235](https://github.com/articlemetrics/lagotto/issues/235))
* added capistrano integration with `vagrant push` command, using [vagrant-capistrano-push](https://github.com/mfenner/vagrant-capistrano-push) plugin ([#238](https://github.com/articlemetrics/lagotto/issues/238))
* updated Mendeley source to use new Mendeley v.1 API ([#239](https://github.com/articlemetrics/lagotto/issues/239))

Make sure the following settings for the Mendeley source are corect:

* **Url**: https://api.mendeley.com/catalog?%{query_string}&view=stats
* **Authentication Url**: https://api.mendeley.com/oauth/token

## Lagotto 3.14 (January 19, 2015)

[Lagotto 3.14](https://github.com/articlemetrics/lagotto/releases/tag/v.3.14) was released on January 19, 2015 with the following change:

* Turned status model into ActiveRecord model, added visualizations of status stats over time ([#233](https://github.com/articlemetrics/lagotto/issues/233))

## Lagotto 3.13 (January 15, 2015)

[Lagotto 3.13](https://github.com/articlemetrics/lagotto/releases/tag/v.3.13) was released on January 15, 2015 with the following changes:

* mention [Lagotto Support Forum](http://discuss.lagotto.io) in `README.md` ([#224](https://github.com/articlemetrics/lagotto/issues/224))
* updated Chef cookbooks to use `shared` folder instead of `current` for better compatibility with Capistrano ([#227](https://github.com/articlemetrics/lagotto/issues/227))
* display rate-limiting information from headers sent by Twitter and Github ([#228](https://github.com/articlemetrics/lagotto/issues/228))
* added automated import from the DataONE ([#231](https://github.com/articlemetrics/lagotto/issues/231))

The big change in this release is the switch from [delayed_job](https://github.com/collectiveidea/delayed_job) to [Sidekiq](https://github.com/mperham/sidekiq) for background processing. Sidekiq requires the `redis` database that can be installed either via the updated Chef scripts, or manually, e.g. on Ubuntu:

```sh
sudo apt-get install redis-server
```

Also, make sure the following ENV variable is set in your `.env` file:

```sh
# number of threads Sidekiq uses
CONCURRENCY=25
```

No redis or sidekiq configuration is necessary, but make sure all `delayed_job` worker processes are killed when upgrading.

## Lagotto 3.12.7 (January 9, 2015)

[Lagotto 3.12.7](https://github.com/articlemetrics/lagotto/releases/tag/v.3.12.7) was released on January 9, 2015 with the following change:

* proper handling of HTML `Page Not Found` errors ([#229](https://github.com/articlemetrics/lagotto/issues/229))
* API keys are no longer required for non-admin API calls ([#230](https://github.com/articlemetrics/lagotto/issues/230))

## Lagotto 3.12.6 (January 6, 2015)

[Lagotto 3.12.6](https://github.com/articlemetrics/lagotto/releases/tag/v.3.12.6) was released on January 6, 2015 with the following change:

* added **works published last day**, **api responses last hour**, and **api requests last hour** to `/heartbeat` API endpoint, and changed status page accordingly ([#226](https://github.com/articlemetrics/lagotto/issues/226))

## Lagotto 3.12.5 (January 6, 2015)

[Lagotto 3.12.5](https://github.com/articlemetrics/lagotto/releases/tag/v.3.12.5) was released on January 6, 2015 with the following change:

* keep `<i>`, `<b>`, `<sup>`, `<sub>`, and `<sc>` HTML tags in work titles, following the [CSL specification on rich text markup](http://citationstyles.org/downloads/upgrade-notes.html#rich-text-markup-within-fields) ([#225](https://github.com/articlemetrics/lagotto/issues/225))

## Lagotto 3.12.4 (January 5, 2015)

[Lagotto 3.12.4](https://github.com/articlemetrics/lagotto/releases/tag/v.3.12.4) was released on January 5, 2015 with the following change:

* Store and display Scopus and Web of Science identifiers ([#221](https://github.com/articlemetrics/lagotto/issues/221))

## Lagotto 3.12.3 (January 4, 2015)

[Lagotto 3.12.3](https://github.com/articlemetrics/lagotto/releases/tag/v.3.12.3) was released on January 4, 2015 with the following change:

* added ORCID as new source ([#220](https://github.com/articlemetrics/lagotto/issues/220))

To load the new source please run

```sh
RAILS_ENV=production bundle exec rake db:seed
```

## Lagotto 3.12.2 (January 4, 2015)

[Lagotto 3.12.2](https://github.com/articlemetrics/lagotto/releases/tag/v.3.12.2) was released on January 4, 2015 with the following changes:

* store blank values for works as `nil`, using the [nilify_blanks](https://github.com/rubiety/nilify_blanks) gem ([#218](https://github.com/articlemetrics/lagotto/issues/218))
* Don't cache worker_count for sources, as otherwise the rate-limiting functionality doesn't work properly ([#219](https://github.com/articlemetrics/lagotto/issues/219))

## Lagotto 3.12.1 (January 4, 2015)

[Lagotto 3.12.1](https://github.com/articlemetrics/lagotto/releases/tag/v.3.12.1) was released on January 4, 2015 with the following changes:

* log responses from external APIs to JSON file in logstash format ([#214](https://github.com/articlemetrics/lagotto/issues/214))
* better handling of ActiveJob errors ([#215](https://github.com/articlemetrics/lagotto/issues/215))
* run daily works import at the end of the day using a new `cron:nightly`rake task, and write to separate `cron_import.log` ([#216](https://github.com/articlemetrics/lagotto/issues/216))
* show all URLs associated with a work (and don't show the citeulike URL if there are no events) ([#217](https://github.com/articlemetrics/lagotto/issues/217))

Starting with this release, the raw responses from external sources are stored in a JSON file `log/agent.log` in logstash format, using the source name and work pid as tags:

```sh
{
  "message": "{\"total_rows\"=>328331, \"offset\"=>121903, \"rows\"=>[{\"id\"=>\"232944431433666561\", \"key\"=>\"10.1371/journal.pone.0042231\", \"value\"=>{\"_id\"=>\"232944431433666561\", \"_rev\"=>\"1-40047ae514c178f154fa7b0f877f146a\", \"text\"=>\"Role of the Irr Protein in the Regulation of Iron Metabolism in Rhodobacter sphaeroides http://t.co/JbOupbjK\", \"from_user_id\"=>38951828, \"from_user_name\"=>\"Test\", \"geo\"=>nil, \"profile_image_url_https\"=>\"https://si0.twimg.com/sticky/default_profile_images/default_profile_6_normal.png\", \"iso_language_code\"=>\"en\", \"to_user_name\"=>nil, \"entities\"=>{\"urls\"=>[{\"expanded_url\"=>\"http://bit.ly/O0DVOi\", \"indices\"=>[88, 108], \"display_url\"=>\"bit.ly/O0DVOi\", \"url\"=>\"http://t.co/JbOupbjK\"}, {\"expanded_url\"=>\"http://www.plosone.org/article/info:doi%2F10.1371%2Fjournal.pone.0042231\", \"display_url\"=>\"http://www.plosone.org/article/info:doi%2F10.1371%2Fjournal.pone.0042231\", \"url\"=>\"http://www.plosone.org/article/info:doi%2F10.1371%2Fjournal.pone.0042231\"}], \"hashtags\"=>[], \"user_mentions\"=>[]}, \"to_user_id\"=>0, \"id\"=>232944431433666560, \"to_user_id_str\"=>\"0\", \"source\"=>\"&lt;a href=&quot;http://twitterfeed.com&quot; rel=&quot;nofollow&quot;&gt;twitterfeed&lt;/a&gt;\", \"from_user_id_str\"=>\"38951828\", \"from_user\"=>\"TestCellBio\", \"created_at\"=>\"Tue, 07 Aug 2012 21:00:55 +0000\", \"to_user\"=>nil, \"id_str\"=>\"232944431433666561\", \"profile_image_url\"=>\"http://a0.twimg.com/sticky/default_profile_images/default_profile_6_normal.png\", \"metadata\"=>{\"result_type\"=>\"recent\"}}}]}",
  "@timestamp": "2015-01-04T01:13:53.387-08:00",
  "@version": "1",
  "severity": "INFO",
  "host": "rwc-prod-alm03",
  "tags": [
    "ActiveJob",
    "SourceJob",
    "2822afb7-1a37-4084-b3c2-b0b87f0370a0",
    "twitter",
    "10.1371/journal.pone.0042231"
  ]
}
```

This file can be further processed with logstash and made available for download.

## Lagotto 3.12 (January 1, 2015)

[Lagotto 3.12](https://github.com/articlemetrics/lagotto/releases/tag/v.3.12) was released on January 1, 2015 with the following changes:

* increased size of `retrieval_statuses.events_url` database column to handle URLs longer than 255 characters ([#205](https://github.com/articlemetrics/lagotto/issues/205))
* upgraded to Rails 4.2 ([#206](https://github.com/articlemetrics/lagotto/issues/206)), and migrated the background worker functionality to the new [ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html) library ([#208](https://github.com/articlemetrics/lagotto/issues/208))
* kept `db:articles:load` task for backwards compatibility ([#207](https://github.com/articlemetrics/lagotto/issues/207))
* added PLOS Fulltext Search as new source ([#209](https://github.com/articlemetrics/lagotto/issues/209))
* added Europe PMC Fulltext Search as new source ([#210](https://github.com/articlemetrics/lagotto/issues/210))
* added import of works via the PLOS Search API ([#211](https://github.com/articlemetrics/lagotto/issues/211))
* added tests of external APIs using [vcr](https://github.com/vcr/vcr) ([#212](https://github.com/articlemetrics/lagotto/issues/212))

The automatic import of works - configured in the `.env` file - has changed:

```sh
# automatic import of works published on current or previous day
# using CrossRef, DataCite, or PLOS Search API, or no automatic import if left empty
# Possible parameters:
# crossref - all works in CrossRef REST API
# member - all works in CrossRef REST API for publishers registered in application
# sample - sample of 20 works from CrossRef REST API
# member_sample - sample of 20 works from CrossRef REST API for publishers registered in application
# datacite - all works in DataCite metadata index
# plos - all PLOS articles
IMPORT=
```

To load the new sources please run

```sh
RAILS_ENV=production bundle exec rake db:seed
```

## Lagotto 3.11 (December 24, 2014)

[Lagotto 3.11](https://github.com/articlemetrics/lagotto/releases/tag/v.3.11) was released on December 24, 2014 with the following changes:

* added Github source (stars and forks for Github repos as works) ([#195](https://github.com/articlemetrics/lagotto/issues/195))
* added authentication options ORCID and Github ([#196](https://github.com/articlemetrics/lagotto/issues/196))
* fixed bug where retrieval_statuses were not created properly for newly added sources ([#197](https://github.com/articlemetrics/lagotto/issues/197))
* import additional CAS attributes (e.g. name) via a second API call ([#198](https://github.com/articlemetrics/lagotto/issues/198))
* fixed a bug introduced in Lagotto 3.10 fetching data from CouchDB ([#203](https://github.com/articlemetrics/lagotto/issues/203))
* fixed a v3 API caching bug ([#204](https://github.com/articlemetrics/lagotto/issues/204))

By default Lagotto uses Mozilla Persona for authentication. To use any of the other authentication options (cas, orcid, github), provide the options in the `.env` file:

```sh
# authentication via orcid, github, cas or persona. Defaults to persona
OMNIAUTH=

GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

ORCID_CLIENT_ID=
ORCID_CLIENT_SECRET=

CAS_URL=
CAS_INFO_URL=
CAS_PREFIX=
```

To load the new Github source please run

```sh
RAILS_ENV=production bundle exec rake db:seed
```

## Lagotto 3.10 (December 18, 2014)

[Lagotto 3.10](https://github.com/articlemetrics/lagotto/releases/tag/v.3.10) was released on December 18, 2014 with the following changes:

* renamed `articles` to `works` to make it clear that the software can track all scholarly outputs ([#190](https://github.com/articlemetrics/lagotto/issues/190))
* support for any unique identifier, including URLs ([#130](https://github.com/articlemetrics/lagotto/issues/130))
* made import of works more modular, and added automatic import from DataCite ([#191](https://github.com/articlemetrics/lagotto/issues/191))

If you are upgrading and have used DOIs as persistent identifier, please run the following rake task to fill in the new `pid_type` and `pid` fields:

```sh
RAILS_ENV=production bundle exec rake db:works:load_pids
```

To load the renamed filters, please run

```sh
RAILS_ENV=production bundle exec rake db:seed
```

## Lagotto 3.9.8 (December 17, 2014)

[Lagotto 3.9.8](https://github.com/articlemetrics/lagotto/releases/tag/v.3.9.8) was released on December 18, 2014 with the following change:

* monitor worker processes directly instead of checking the PID file ([#194](https://github.com/articlemetrics/lagotto/issues/194))

## Lagotto 3.9.7 (December 11, 2014)

[Lagotto 3.9.7](https://github.com/articlemetrics/lagotto/releases/tag/v.3.9.7) was released on December 11, 2014 with the following change:

* use more specific search string in `twitter_search`, and make the search string configurable in the source settings ([#189](https://github.com/articlemetrics/lagotto/issues/189))

Please change `url` in the `twitter_search` source to

```
https://api.twitter.com/1.1/search/tweets.json?q="%{doi}" OR "%{query_url}"&count=100&include_entities=1&result_type=recent
```

Change `events_url` to

```
https://twitter.com/search?q="%{doi}" OR "%{query_url}"&f=realtime
```

## Lagotto 3.9.6 (December 5, 2014)

[Lagotto 3.9.6](https://github.com/articlemetrics/lagotto/releases/tag/v.3.9.6) was released on December 5, 2014 with the following changes:

* use logstash json format for logging only in production environment.
* consolidated cron jobs into one rake task each for hourly, daily, weekly and monthly tasks
* bugfix in automated CrossRef import

## Lagotto 3.9.5 (December 4, 2014)

[Lagotto 3.9.5](https://github.com/articlemetrics/lagotto/releases/tag/v.3.9.5) was released on December 4, 2014 with the following change:

* use logstash json format for logging. Optionally store logs in redis using `ENV["LOGSTASH_TYPE"]=redis` and `ENV["LOGSTASH_HOST"]=example.com`.

## Lagotto 3.9.4 (December 2, 2014)

[Lagotto 3.9.4](https://github.com/articlemetrics/lagotto/releases/tag/v.3.9.4) was released on December 2, 2014 with the following change:

* set `Delayed::Worker.sleep_delay` (the delayed_jobs polling interval of MySQL) via ENV["DJ_SLEEP_DELAY"], defaulting to 5 sec ([#188](https://github.com/articlemetrics/lagotto/issues/188))

## Lagotto 3.9.3 (November 26, 2014)

[Lagotto 3.9.3](https://github.com/articlemetrics/lagotto/releases/tag/v.3.9.3) was released on November 26, 2014 with the following change:

* improved HTTP caching by adding `rack::deflater` middleware and better use of `Last-Modified` header in v5 API ([#187](https://github.com/articlemetrics/lagotto/issues/187))

## Lagotto 3.9.2 (November 26, 2014)

[Lagotto 3.9.2](https://github.com/articlemetrics/lagotto/releases/tag/v.3.9.2) was released on November 26, 2014 with the following change:

* fixed Facebook URL for installations using the depreciated Graph API ([#186](https://github.com/articlemetrics/lagotto/issues/186))

## Lagotto 3.9.1 (November 8, 2014)

[Lagotto 3.9.1](https://github.com/articlemetrics/lagotto/releases/tag/v.3.9.1) was released on November 8, 2014 with the following changes:

* added support for the [better_errors](https://rubygems.org/gems/better_errors) gem in development mode ([#181](https://github.com/articlemetrics/lagotto/issues/181))
* use Rails 4 binstubs for `rake`, `rails`, `cap` and `whenever` ([#182](https://github.com/articlemetrics/lagotto/issues/182))
* changed the layout of the static markdown files to resemble the rest of the site layout ([#183](https://github.com/articlemetrics/lagotto/issues/183))
* fixed a bug in the CrossRef automatic import rake task ([#184](https://github.com/articlemetrics/lagotto/issues/184))
* removed the [faraday_cookie_jar](https://github.com/miyagawa/faraday-cookie_jar) gem, as it is a possible reason for utf-8 errors that can kill background workers ([#185](https://github.com/articlemetrics/lagotto/issues/185))

## Lagotto 3.9 (November 7, 2014)

[Lagotto 3.9](https://github.com/articlemetrics/lagotto/releases/tag/v.3.9) was released on November 7, 2014 with the following changes:

* switched from **rabl** to **jbuilder** for generating JSON API responses, fixing [#179](https://github.com/articlemetrics/lagotto/issues/179), and discontinuing XML support in the depreciated v3 API
* moved `SECRET_KEY_BASE` into the Rails 4.1 `secrets.yml` file

## Lagotto 3.8.1 (November 5, 2014)

[Lagotto 3.8.1](https://github.com/articlemetrics/lagotto/releases/tag/v.3.8.1) was released on November 5, 2014 with the following changes:

* fixed a bug precompiling assets: `...public/assets/manifest*': No such file or directory`
* many other small bug fixes
* added new `LOG_LEVEL` option for rails and capistrano to `.env`

## Lagotto 3.8 (November 4, 2014)

[Lagotto 3.8](https://github.com/articlemetrics/lagotto/releases/tag/v.3.8) was released on November 4, 2014 with the following changes:

* upgraded to Rails 4 and Rspec 3 ([#129](https://github.com/articlemetrics/lagotto/issues/129))

Please change `SECRET_TOKEN` in your `.env` file to `SECRET_KEY_BASE`.

## Lagotto 3.7.1 (October 31, 2014)

[Lagotto 3.7.1](https://github.com/articlemetrics/lagotto/releases/tag/v.3.7.1) was released on October 31, 2014 with the following features and bug fixes:

* upgraded to Rails 4 asset pipeline ([#172](https://github.com/articlemetrics/lagotto/issues/172))
* show all open alerts, not just those from the last 24 hours ([#173](https://github.com/articlemetrics/lagotto/issues/173))
* handle multiple `.env` files via `DOTENV` ENV variable, default to `DOTENV=default` ([#174](https://github.com/articlemetrics/lagotto/issues/174))
* fixed an error picking up publisher-specific settings for the CrossRef source ([#176](https://github.com/articlemetrics/lagotto/issues/176))
* show an alert on the status page also when patch level version (e.g.. 3.7.x) is outdated, not just minor or major version differences.

## Lagotto 3.7 (October 28, 2014)

[Lagotto 3.7](https://github.com/articlemetrics/lagotto/releases/tag/v.3.7) was released on October 28, 2014 with the following features and bug fixes:

* simplified configuration: use ENV variables and consolidate configuration for Rails, Capistrano, Chef and Vagrant into a single `.env` file. See below for more information ([#146](https://github.com/articlemetrics/lagotto/issues/146))
* raise alert on the admin status page if not running the latest Lagotto version. This feature checks for the [latest release in the Lagotto Github repo](https://github.com/articlemetrics/lagotto/releases) using pessimistic version constraints, e.g. `"~> 3.6.3"` ([#155](https://github.com/articlemetrics/lagotto/issues/155))
* facelift of the admin panel layout ([#156](https://github.com/articlemetrics/lagotto/issues/156))
* adapted to changes in the Facebook API ([#90](https://github.com/articlemetrics/lagotto/issues/90)). Lagotto now automatically
  fetches the authentication token from a given `app_key` and `app_secret`. Since the release of the v2.1 API in August 2014 the **link_stat** API endpoint is depreciated. New user accounts have to use the v2.1 API and only get the total count of Facebook activity, whereas users will older API keys can still use the **link_stat** API and get the number of shares, comments and likes in addition to the total count by adding the following `link_stat URL` in the Facebook configuration:

```sh
https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'
```

* don't cache in Rails development mode ([#157](https://github.com/articlemetrics/lagotto/issues/157))
* many small bug fixes ([#147](https://github.com/articlemetrics/lagotto/issues/147), [#148](https://github.com/articlemetrics/lagotto/issues/148), [#149](https://github.com/articlemetrics/lagotto/issues/149), [#150](https://github.com/articlemetrics/lagotto/issues/150), [#151](https://github.com/articlemetrics/lagotto/issues/151), [#152](https://github.com/articlemetrics/lagotto/issues/152), [#153](https://github.com/articlemetrics/lagotto/issues/153), [#154](https://github.com/articlemetrics/lagotto/issues/154))

Starting with the Lagotto 3.7 release all user-specific configuration options for Rails, as well as for the server configuration and deployment tools Vagrant, Chef and Capistrano are environment variables, and can be stored in a single `.env` file. An example file is provided (`.env.example`) and can be used without modifications for a development server. More information regarding ENV variables and `.env` is available [here](https://github.com/bkeepers/dotenv). The following configuration options need to be set:

```sh
# Example configuration settings for this application

APPLICATION=lagotto

# database settings
DB_NAME=lagotto
DB_USERNAME=vagrant
DB_PASSWORD=
DB_HOST=localhost

# internal name of server
HOSTNAME=lagotto.local

# public name of server
# can be HOSTNAME, or different if load balancer is used
SERVERNAME=lagotto.local

# all instances of server used behind load balancer
# can be HOSTNAME, or comma-delimited string of HOSTNAME
SERVERS=lagotto.local

# name used on navigation bar and in email subject line
SITENAME=ALM

# couch_db database
COUCHDB_URL=http://localhost:5984/lagotto

# email address for sending emails
ADMIN_EMAIL=admin@example.com

# number of background workers
WORKERS=3

# automatic import via CrossRef API.
# Use 'all', 'member', 'sample', 'member_sample', or leave empty
IMPORT=

# persistent identifier used
UID=doi

# keys
# run `rake secret` to generate these keys
API_KEY=8897f9349100728d66d64d56bc21254bb346a9ed21954933
SECRET_TOKEN=c436de247c988eb5d0908407e700098fc3992040629bb8f98223cd221e94ee4d15626aae5d815f153f3dbbce2724ccb8569c4e26a0f6f663375f6f2697f1f3cf

# mail settings
MAIL_ADDRESS=localhost
MAIL_PORT=25
MAIL_DOMAIN=localhost

# vagrant settings
PRIVATE_IP=10.2.2.4

AWS_KEY=
AWS_SECRET=
AWS_KEYNAME=
AWS_KEYPATH=

DO_PROVIDER_TOKEN=
DO_SIZE=1GB
SSH_PRIVATE_KEY='~/.ssh/id_rsa'

# user and group who own application repository
DEPLOY_USER=vagrant
DEPLOY_GROUP=vagrant

# mysql server root password for chef
DB_SERVER_ROOT_PASSWORD=EZ$zspyxF2
```

The Mendeley configuration variable `secret` has been renamed to `client_secret` to be more consistent with other OAuth2 applications, please update your configuration.

## Lagotto 3.6.3 (October 12, 2014)

[Lagotto 3.6.3](https://github.com/articlemetrics/lagotto/releases/tag/v.3.6.3) was released on October 12, 2014 with the following features:

* faster filtering and sorting of articles (through additional indexes and caching)
* filter v5 API responses by source, and sort them by event count or date (#136)
* Turned very slow SQL insert statement into multiple background jobs (#137)
* many small bug fixes

## Lagotto 3.6.2 (October 10, 2014)

[Lagotto 3.6.2](https://github.com/articlemetrics/lagotto/releases/tag/v.3.6.2) was released on October 10, 2014 with the following features:

* improved caching of the admin dashboard
* optimized SQL queries for listing articles

## Lagotto 3.6 (October 8, 2014)

[Lagotto 3.6](https://github.com/articlemetrics/lagotto/releases/tag/v.3.6) was released on October 8, 2014 with the following features and bugfixes:

* added publisher information to articles and enabled import of publisher information from CrossRef
* list articles by publisher
* enabled publisher-specific source configuration for CrossRef and PMC Usage Stats
* associate user accounts with publishers, and allow these users to change publisher-specific source configuration
* Upgrade to Rails 3.2.19
* fixed problem with generation of monthly reports for counter, pmc and mendeley
* many small bug fixes

Users upgrading from earlier versions need to make the following changes:

* Add at least one publisher, and associate at least one user account with this publisher (in the account profile for admin/staff accounts, by an admin for user accounts)
* Add publisher-specific settings to the `CrossRef` and `PMC` source. Add `Openurl username` to CrossRef if you plan to collect citation counts for articles where you are not the publisher.

## Lagotto 3.5 (September 14, 2014)

With this release the ALM application was renamed to Lagotto and the license changed
from Apache 2.0 to a MIT license. [Lagotto 3.5](https://github.com/articlemetrics/lagotto/releases/tag/v.3.5) was released on September 14, 2014
with the following features and bugfixes:

* updated automated installation with Chef/Vagrant to use Ubuntu 14.04 and Nginx,
  and simplified and tested the Chef cookbook
* updated the manual installation instructions, and added a new page with deployment instructions
* fixed a bug with caching JSONP API responses
* improved caching of the admin dashboard by moving to model caching for slow queries

## ALM 3.4.8 (August 28, 2014)

[ALM 3.4.8](https://github.com/articlemetrics/alm/releases/tag/v.3.4.8) was released on August 28, 2014 with the following bugfix:

* don't send email alerts for delayed_job errors

## ALM 3.4.2 (August 24, 2014)

[ALM 3.4.2](https://github.com/articlemetrics/alm/releases/tag/v.3.4.2) was released on August 24, 2014 with the following bugfix:

* fixed issue with caching of the admin panel

## ALM 3.4 (August 22, 2014)

[ALM 3.4](https://github.com/articlemetrics/alm/releases/tag/v.3.4) was released on August 22, 2014 with the following new features:

* better caching of the admin panel
* simplified admin panel navigation, and more information made available to regular users
* publisher model with support for automated article import via CrossRef API
* more granular error reporting with levels `INFO`, `WARN`, `ERROR`and `FATAL`
* Alerts API for admin users
* new `/heartbeat` API endpoint to check application health
* many bug fixes

To enable the automated daily article import via CrossRef API, add the following line to `config/settings.yml`:

```yaml
import: member
```

To import articles manually, leave import empty; or use one of the following options for automated daily import via cron:

* `import: all`: All DOIs updated the last day
* `import: sample`: A random sample of 20 from all DOIs updated the last day
* `import: member`: All DOIs from the publishers in the publisher admin interface, updated the last day
* `import: member_sample`: A random sample of 20 from all DOIs from the publishers in the publisher admin interface, updated the last day

Publishers can now be added in the admin interface. The only functionality is currently the automated article import described above.

For admin users alerts are now available via API, use the `/api/v4/alerts` endpoint and basic authentication. More details in the API documentation.

There is one configuration change in error reporting: the `disabled_source_report` has been renamed to `fatal_error_report`, as an immediate email will now be sent for all errors with severity `FATAL`. To rename the report template in the database, run this rake task once (using the appropriate `RAILS_ENV`):

```
bundle exec rake mailer:rename_report RAILS_ENV=production
```

## ALM 3.3.19 (August 18, 2014)

[ALM 3.3.19](https://github.com/articlemetrics/alm/releases/tag/v.3.3.19) was released on August 18, 2014 with the following new feature:

* set background worker priority individually for every source

## ALM 3.3.14 (August 15, 2014)

[ALM 3.3.14](https://github.com/articlemetrics/alm/releases/tag/v.3.3.14) was released on August 15, 2014 with the following bugfix:

* fixed bug with oEmbed functionality

## ALM 3.3.12 (August 13, 2014)

[ALM 3.3.12](https://github.com/articlemetrics/alm/releases/tag/v.3.3.12) was released on August 13, 2014 with the following new feature:

* added rake task to delete CouchDB history documents (which are no longer needed). Use `START_DATE` and `END_DATE`.

```
bundle exec rake couchdb:histories:delete START_DATE=2014-01-01
```

## ALM 3.3.8 (August 8, 2014)

[ALM 3.3.8](https://github.com/articlemetrics/alm/releases/tag/v.3.3.8) was released on August 8, 2014 with the following bugfix:

* unescape URLs in the oembed controller

## ALM 3.35 (August 5, 2014)

[ALM 3.3.5](https://github.com/articlemetrics/alm/releases/tag/v.3.3.5) was released on August 5, 2014 with the following bugfix:

* handle larger delayed_job payloads (up to 16 MB)

## ALM 3.3.2 (August 3, 2014)

[ALM 3.3.2](https://github.com/articlemetrics/alm/releases/tag/v.3.3.2) was released on August 3, 2014 with the following bugfixes:

* fixed a problem where the same cached response was used by both the v3 and v5 API
* fixed a bug where some dates from events where incorrently formatted

## ALM 3.3.1 (July 31, 2014)

[ALM 3.3.1](https://github.com/articlemetrics/alm/releases/tag/v.3.3.1) was released on July 31, 2014 with the following bugfix:

* allow import of articles that contain non utf-8 characters in the title

## ALM 3.3 (July 29, 2014)

[ALM 3.3](https://github.com/articlemetrics/alm/releases/tag/v.3.3) was released on July 29, 2014 with the following features:

* import of articles via the CrossRef API
* support for oEmbed
* performance improvements
* better handling of not found errors
* better support for multiple ALM servers

## ALM 3.2 (July 1, 2014)

[ALM 3.2](https://github.com/articlemetrics/alm/releases/tag/v.3.2) was released on July 1, 2014 with the following features:

* removed all dependencies on retrieval_histories table (which will be dropped in a future release)
* finished work on v5 API (first released in ALM 2.14), which should now be stable
* search Twitter by DOI or URL
* added brakeman security scanner to continuous integration setup
* bug fixes

## ALM 3.1 (May 23, 2014)

[ALM 3.1](https://github.com/articlemetrics/alm/releases/tag/v.3.1) was released on May 23, 2014 with the following features:

* display of all events for an article by date
* many bug fixes

# ALM 3.0 (May 8, 2014)

[ALM 3.0](https://github.com/articlemetrics/alm/releases/tag/v.3.0) was released on May 8, 2014 with the following features:

* rewrite of all sources
* rewrite of backend processing of source API responses
* daily and monthly visualizations for all sources
* standardized events in CSL format
* Rails 3.2.18

## ALM 2.14 (April 24, 2014)

[ALM 2.14](https://github.com/articlemetrics/alm/releases/tag/v.2.14) was released on April 24, 2014 with the following new features:

* extensive refactoring of background workers for sources
* fixed some open issues with displaying information using the d3.js library (and included Jasmine Javascript unit tests)
* full support for using the pmid or pmcid instead of the doi as required persistent identifier for every article
* improved support for Capistrano 3
* many bug fixes

## ALM 2.13.2 (March 27, 2014)

[ALM 2.13.2](https://github.com/articlemetrics/alm/releases/tag/v.2.13.2) was released on March 27, 2014 with a focus on bug fixes:

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

## ALM 2.12.1 (February 10, 2014)

[ALM 2.12.1](https://github.com/articlemetrics/alm/releases/tag/v.2.12.1) was released on February 10, 2014 with the following changes:

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

## ALM 2.11.2 (January 22, 2014)

[ALM 2.11.2](https://github.com/articlemetrics/alm/releases/tag/v.2.11.2) was released on January 22, 2014. Changes in this release include:

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

## ALM 2.10.1 (November 13, 2013)

[ALM 2.10.1](https://github.com/articlemetrics/alm/releases/tag/v.2.10.1) was released on November 13, 2013 with the following features:

* improve dashboard performance
* improve reporting
* merged DOI import code from CrossRef

## ALM 2.9.15 (November 3, 2013)

[ALM 2.9.15](https://github.com/articlemetrics/alm/releases/tag/v.2.9.15) was released on November 3, 2013. This release contains fixes for the mailer functionality and two new reports:

* status report
* disabled source report

A new source has been added:

* DataCite

## ALM 2.9.7 (October 3, 2013)

[ALM 2.9.7](https://github.com/articlemetrics/alm/releases/tag/v.2.9.7) was released on October 3, 2013. This release fixes many small bugs of the 2.9 release and adds the following new sources:

* PMC Europe Citations
* PMC Europe Database Links
* Reddit
* Wordpress.com
* OpenEdition

## ALM 2.9 (September 16, 2013)

[ALM 2.9](https://github.com/articlemetrics/alm/releases/tag/v.2.9) was released on September 16, 2013. This version contains numerous bug fixes, and some important parts of the application were refactored

* all HTTP calls to external APIs now use the Faraday library, with automatic JSON decoding and central error logging
* the duration of responses from external APIs is now logged and displayed
* XML parsing was cleaned up and consolidated into the nokogiri gem
* background processing has been simplified
* the automatic installation with Vagrant was improved and the documentation updated

The major new feature in this release is error tracking via filters. Filters can easily be added and customized, and they will generate a daily error report that is sent out via email

## ALM 2.8 (July 22, 2013)

[ALM 2.8](https://github.com/articlemetrics/alm/releases/tag/v.2.8) was released on July 22, 2013. The development work focused on user account management.

#### User accounts

Prior to this release, the ALM application allowed only a single user account. We can now have multiple user accounts, plus different roles for them:

* API user - to obtain an API key
* staff - read-only access to the admin dashboard
* admin - full access to the admin dashboard

A new user admin dashboard facilitates user management.

#### Social login

To facilitate account management for users and ALM admins, new user accounts can only be created via social login with one of these services:

* [Github OAuth](http://developer.github.com/v3/oauth/)
* [Mozilla Persona](http://www.mozilla.org/en-US/persona/)

The ALM application can be configured to use one of these services (but not both), or to use the old system of only a single admin user. The documentation has been updated to reflect these changes.

#### API keys

Now that API keys are created within the ALM application, we can check for valid API keys in every API request. This is currently only done to allow access to private sources for admins, and to enable create/update/delete in the REST API. For security reasons create/update/delete only works from requests originating from the same computer.

#### Documentation

The documentation in the wiki is now included in the application, making it easier for users to find documentation. We use the [github-markdown gem](http://rubygems.org/gems/github-markdown) for this. The documentation has been updated with the changes in ALM 2.8, and other updates.

#### Other Changes

Many small changes and bug fixes. We now use memcached for caching, and we added to cron jobs to clean up temporary tables (error_messages and api_requests).

## ALM 2.7 (May 16, 2013)

[ALM 2.7](https://github.com/articlemetrics/alm/releases/tag/v.2.7) was released on May 16, 2013. The development work focused on adding Javascript libraries that talk to the ALM API and can be embedded in other web sites.

#### Javascript single article visualizations

We added visualizations for single articles using the d3.js library, including time-based visualizations by day, month and year. We have created a new [Github repository](https://github.com/articlemetrics/almviz) that will hold all future work on Javascript libraries talking to the ALM API. To make these visualizations easier we made two changes to the [v3 ALM API](API):

* added signposts (views, shares, bookmarks, citations) as summary information
* added metrics by day, month and year for every source

#### Other Changes

We have made it easier to install the ALM application by adding and testing support for Amazon AWS via Vagrant. We added rake tasks to seed or delete articles, and to delete resolved errors and old API requests. Many small bugs were fixed and the ALM application was updated to use the latest Rails version (3.2.13).

## ALM 2.6 (March 19, 2013)

[ALM 2.6](https://github.com/articlemetrics/alm/releases/tag/v.2.6) was released on March 19, 2013. The development work focused on two areas: API performance and easy installation.

#### API Performance

The API code was refactored, adding the [Draper Decorator](https://github.com/drapergem/draper) between the model and the [RABL Views](https://github.com/nesquena/rabl). We added caching, using Russian Doll fragment caching as described [here](http://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works). It required some extra work to make this work with RABL and Draper. We also added a visualization of API requests to the admin dashboard, using d3.js and the [crossfiler](http://square.github.com/crossfilter/) library.

#### Easy Installation

To make it easier to install the ALM application, we have updated and throughoutly tested the [manual installation](installation) instructions, updated the Chef / Vagrant automated installation (now using Ubuntu 12.04 and linking directly to the Chef Cookbook repository), and provided a VMware image of ALM application (535 MB [download](http://dl.dropbox.com/u/9406373/alm_ubuntu_12.04_vmware.tar.gz), username/password: alm). The VMware image file is still experimental and feedback is appreciated.

An updated version of [Vagrant](http://docs.vagrantup.com/v2/getting-started/index.html) (1.1) was released days after ALM 2.6, and this version now supports VMware and AWS. We will support these platforms in a future ALM release to again make it easier to test or install the ALM application.

#### Other Changes

This release includes many small fixes and improvements. Of particular interest are the RSS feeds for the most popular articles by source, published in the last 7 days, 30 days, 12 months, or all-time. The RSS feeds are link from the most-cited lists for each source, e.g. [here](http://alm.plos.org/sources/twitter).

## ALM 2.5 (February 1, 2013)

[ALM 2.5](https://github.com/articlemetrics/alm/releases/tag/v.2.5) was released on February 1, 2013.

* admin dashboard
* First visualizations based on d3.js
* RSS feeds
* Rails 3.2.11

## ALM 2.4 (December 20, 2012)

[ALM 2.4](https://github.com/articlemetrics/alm/releases/tag/v.2.4) was released on December 20, 2012.

In this release we added a new source ([ScienceSeeker](http://scienceseeker.org/), a blog aggregator), fix many errors with sources and added tests for background and Rake tasks.

## ALM 2.3 (October 30, 2012)

[ALM 2.3](https://github.com/articlemetrics/alm/releases/tag/v.2.3) was released on October 30, 2012.

* updated API (v3)

## ALM 2.2 (October 5, 2012)

[ALM 2.2](https://github.com/articlemetrics/alm/releases/tag/v.2.2) was released on October 5, 2012.

* added Twitter Bootstrap CSS framework
* many small bug fixes and tweaks
* Rails 3.2.8

## ALM 2.1 (September 13, 2012)

[ALM 2.1](https://github.com/articlemetrics/alm/releases/tag/v.2.1) was released on September 13, 2012.

* moved source code to Github
* added Rspec and Cucumber test coverage
* added installation script using Vagrant and Chef
* added Wikipedia source
* Rails 3.2.7

## ALM 2.0 (July 31, 2012)

[ALM 2.0](https://github.com/articlemetrics/alm/releases/tag/v.2.0) was released on July 31, 2012.

* Ruby 1.9.3 and Rails 3.2.3
* switched from workling/starling to delayed_job for workers
* major refactoring of background processes
* store source data in CouchDB
