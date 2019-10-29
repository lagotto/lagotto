    .____                           __    __
    |    |   _____     ____   _____/  |__/  |_  ____
    |    |   \__  \   / ___\ /  _ \   __\   __\/  _ \
    |    |___ / __ \_/ /_/  >  <_> )  |  |  | (  <_> )
    |_______ (____  /\___  / \____/|__|  |__|  \____/
            \/    \//_____/


build: [![Build Status Badge]][Build Status]&#8193;&#9733;&#8193;
integration: [![Integration Status Badge]][Integration Status]

## Overview

Lagotto is an Open Source application started in March 2009 by the Open Access
publisher Public Library of Science (PLOS). Lagotto retrieves data from a wide
set of services (sources). Some of these sources represent the actual channels
where users are directly viewing, sharing, discussing, citing, recommending the
works (e.g., Twitter and Mendeley). Others are third-party vendors which provide
this information (e.g., CrossRef for citations).

To see Lagotto in action, visit http://alm.plos.org/

## RSpec Tests

Lagotto has a pretty comprehensive set of RSpec tests. Unfortunately, most of
them are broken -- sigh. What to do? Fix them as we can especially when we fix a
bug or add a feature -- fix the accompanying test too.

We've updated the RSpec configuration to only run tests that have been
explicitly enabled with focus:true (ex: spec/models/cross_ref_spec.rb).


#### MySQL DB

The RSpec tests require a MySQL database named lagotto_test, so the first thing
to do is create this database plus a user. See .env.rspec for a listing of all
properties used in the tests.

    mysql -u root -p<password>

    CREATE DATABASE lagotto_test /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

    CREATE USER 'lagotto'@'localhost' IDENTIFIED BY '';
    GRANT ALL PRIVILEGES ON lagotto_test.* TO 'lagotto'@'localhost' WITH GRANT OPTION;
    FLUSH PRIVILEGES;

Create tables in schema

    rake db:setup RAILS_ENV=test


#### Couch DB

~~The tests also depend on a local Couchdb instance (http://localhost:5984), so
you need to have that running too. You can spin one up in a Docker if inclined
(see https://github.com/klaemo/docker-couchdb).~~

The specs don't seem to require couchdb anymore. Perhaps because the individual
specs that required it have been disabled.


#### Running Tests

You're now setup to run the rspec tests (only the ones which have been enabled).

    $ bundle exec rspec

        Run options: include {:focus=>true}
        ...............................*.......................*....
        85 examples, 0 failures, 2 pending


You can run the rspec tests in a deployed version too (via Capistrano).

    ssh lagotto.vagrant.local

    $ mysql -h 127.0.0.1 -u root -p<password>
    // create schema and user (see above)

    $ sudo -u lagotto -i
    $ cd /var/www/lagotto/current
    $ bundle install --with test
    $ DOTENV=rspec bin/rake db:setup RAILS_ENV=test
    $ DOTENV=rspec bin/rspec

## Docker

### Running the application

Build the lagotto image
```
docker-compose build
```
Run lagotto
```
docker-compose up
```
After a few seconds of start up time, navigate to http://localhost:8080 in your
browser.

If you would like to initialize some seed data, run
```
docker-compose exec -e SEED_SOURCES=true appserver bundle exec rake db:seed
```

To stop the application, use `ctrl-c`. To clean up the containers and volumes run:
```
docker-compose down -v
```

### Running the tests

Unless you configure it otherwise, the same database will be used for
RAILS_ENV=test and RAILS_ENV=production in docker-compose. It may not strictly
be necessary, but I recommend destroying your containers before and after
running the tests in docker-compose so you the Development and Test data don't
pollute eachother.
```
docker-compose down -v
```
Build the image
```
docker-compose build
```
Set up the database
```
docker-compose run --rm -e RAILS_ENV=test appserver docker/wait-for.sh db:3306 -- rake db:setup
```
Run the specs
```
docker-compose run --rm appserver rspec
```
Clean up
```
docker-compose down -v
```

### Testing subscribers

Subscribers can be configured to be notified when citations reach specific milestones.

In one console window, rebuild with minimal test data. Watch the container logs here.
```
docker-compose down -v
docker-compose up --build
docker-compose exec appserver rake db:seed
```

Start a rails console in a new window.
```bash
docker exec -it lagotto_appserver_1 rails c
Loading production environment (Rails 4.2.7.1)
```
Fetch new data and trigger a notification of a subscriber.
```ruby
Source.find_by(name: 'simple_source').retrieval_statuses.last.perform_get_data
```
```
Notifying subscriber: {:url=>"http://test_subscriber:9055/notify-me-please", :doi=>"10.1371/journal.pcbi.0010052", :milestone=>1}
Response from subscriber: #<Faraday::Response:0x00559db2d27da0 @on_complete_callbacks=[], @env=#<Faraday::Env @method=:get @body="test subscriber called" @url=#<URI::HTTP http://test_subscriber:9055/notify-me-please?doi=10.1371%2Fjournal.pcbi.0010052&milestone=1> @request=#<Faraday::RequestOptions (empty)> @request_headers={"User-Agent"=>"Faraday v0.9.2"} @ssl=#<Faraday::SSLOptions (empty)> @response=#<Faraday::Response:0x00559db2d27da0 ...> @response_headers={"Server"=>"nginx/1.16.0", "Date"=>"Tue, 29 Oct 2019 23:38:19 GMT", "Content-Type"=>"application/octet-stream", "Content-Length"=>"22", "Connection"=>"keep-alive"} @status=200>>
=> {:total=>10, :html=>0, :pdf=>0, :previous_total=>0, :skipped=>false, :update_interval=>1}
```
And in the docker-compose logs you'll see an entry from the test_subscriber container:
```
test_subscriber_1  | 192.168.16.5 - - [29/Oct/2019:23:38:19 +0000] "GET /notify-me-please?doi=10.1371%2Fjournal.pcbi.0010052&milestone=1 HTTP/1.1" 200 22 "-" "Faraday v0.9.2" "-"
```

[Build Status]: https://teamcity.plos.org/teamcity/viewType.html?buildTypeId=Alm_LagottoRspecTests
[Build Status Badge]: https://teamcity.plos.org/teamcity/app/rest/builds/buildType:(id:Alm_LagottoRspecTests)/statusIcon.svg

[Integration Status]: https://teamcity.plos.org/teamcity/viewType.html?buildTypeId=IntegrationTests_LagottoDev
[Integration Status Badge]: https://teamcity.plos.org/teamcity/app/rest/builds/buildType:(id:IntegrationTests_LagottoDev)/statusIcon.svg
