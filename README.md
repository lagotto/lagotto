    .____                           __    __          
    |    |   _____     ____   _____/  |__/  |_  ____  
    |    |   \__  \   / ___\ /  _ \   __\   __\/  _ \ 
    |    |___ / __ \_/ /_/  >  <_> )  |  |  | (  <_> )
    |_______ (____  /\___  / \____/|__|  |__|  \____/ 
            \/    \//_____/                           


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

    CREATE USER 'vagrant'@'localhost' IDENTIFIED BY '';
    GRANT ALL PRIVILEGES ON lagotto_test.* TO 'vagrant'@'localhost' WITH GRANT OPTION;
    FLUSH PRIVILEGES;

Create tables in schema

    rake db:setup RAILS_ENV=test


#### Couch DB

The tests also depend on a local Couchdb instance (http://localhost:5984), so
you need to have that running too. You can spin one up in a Docker if inclined
(see https://github.com/klaemo/docker-couchdb).


#### Running Tests

You're now setup to run the rspec tests (only the ones which have been enabled).

    $ DOTENV=rspec bin/rspec

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
