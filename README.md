    .____                           __    __          
    |    |   _____     ____   _____/  |__/  |_  ____  
    |    |   \__  \   / ___\ /  _ \   __\   __\/  _ \ 
    |    |___ / __ \_/ /_/  >  <_> )  |  |  | (  <_> )
    |_______ (____  /\___  / \____/|__|  |__|  \____/ 
            \/    \//_____/                           


build: [![Build Status Badge]][Build Status]&#8193;&#9733;&#8193;
integration: [![Integration Status Badge]][Integration Status]

## Overview

    TODO

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
Initialize the database. This command might fail the first time if the mysql
server doesn't start listening in time. If it does, just run it again.
```
docker-compose run app rake db:setup
```
Run lagotto
```
docker-compose up
```
After a few seconds of start up time, navigate to http://localhost:8080 in your
browser.

To stop it, use `ctrl-c`. To clean up the containers and volumes run:
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
Set up the database. Like above, if this fails the first time, try it again.
```
docker-compose run -e RAILS_ENV=test app rake db:setup
```
Run the specs
```
docker-compose run app rspec
```
Clean up
```
docker-compose down -v
```

[Build Status]: https://teamcity.plos.org/teamcity/viewType.html?buildTypeId=Alm_LagottoRspecTests
[Build Status Badge]: https://teamcity.plos.org/teamcity/app/rest/builds/buildType:(id:Alm_LagottoRspecTests)/statusIcon.svg

[Integration Status]: https://teamcity.plos.org/teamcity/viewType.html?buildTypeId=IntegrationTests_LagottoDev
[Integration Status Badge]: https://teamcity.plos.org/teamcity/app/rest/builds/buildType:(id:IntegrationTests_LagottoDev)/statusIcon.svg
