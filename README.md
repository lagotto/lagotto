Article Level Metrics (ALM), is a Ruby on Rails application started by the [Public Library of Science (PLOS)](http://www.plos.org/). It stores and reports user configurable performance data on research articles. Examples of possible metrics are online usage, citations, social bookmarks, notes, comments, ratings and blog coverage.

For more information on how PLOS uses Article-Level Metrics, see [http://article-level-metrics.plos.org/](http://article-level-metrics.plos.org/).

Version 2.0 of the application was released in July 2012 and has been updated to be compatible with Ruby 1.9.3, Rails 3.2.x, and to store the results of external API calls in CouchDB. The backend processes have been completely rewritten and now uses **delayed_job**.

## Installation

Article Level Metrics (ALM), is a Ruby on Rails application started by the [Public Library of Science (PLOS)](http://www.plos.org/). It stores and reports user configurable performance data on research articles. Examples of possible metrics are online usage, citations, social bookmarks, notes, comments, ratings and blog coverage.

For more information on how PLOS uses Article-Level Metrics, see [http://article-level-metrics.plos.org/](http://article-level-metrics.plos.org/).

Version 2.0 of the application was released in July 2012 and has been updated to be compatible with Ruby 1.9.3, Rails 3.2.x, and to store the results of external API calls in CouchDB. The backend processes have been completely rewritten and now uses **delayed_job**.

## Installation

ALM is a standard Ruby on Rails application with the following requirements:

* Ruby 1.9.3
* CouchDB 1.1

CouchDB is used to store the responses from external API calls, MySQL is used for everything else. The application has been tested with Apache/Passenger, but should also run in other deployment environments, e.g. Nginx/Unicorn or WEBrick. ALM uses Ruby on Rails 3.2.x.

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

### Manual installation
These instructions assume a default installation of Ubuntu 12.04.

#### Update package lists

    sudo apt-get update

#### Install RVM, Ruby 1.9.3 and RubyGems
RVM (Ruby Version Manager) is the standard tool to install Ruby and Rubygems: http://rvm.io

    # Install required packages
    sudo apt-get install curl git-core patch \
    build-essential bison zlib1g-dev libssl-dev libxml2-dev \
    libxml2-dev sqlite3 libsqlite3-dev autotools-dev \
    libxslt1-dev libyaml-0-2 autoconf automake libreadline6-dev \
    libyaml-dev libtool

    # multi-user install
    curl -L https://get.rvm.io | sudo bash -s stable
    sudo adduser deploy rvm
    sudo rvm install ruby-1.9.3
    rvm --default use 1.9.3
    
#### Install databases

    sudo apt-get install couchdb
    sudo apt-get install mysql-server

#### Install Apache and dependencies required for Passenger

    sudo apt-get install apache2 libcurl4-openssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev

#### Install and configure Passenger
Passenger is a Rails application server: http://www.modrails.com

    rvmsudo gem install passenger
    rvmsudo passenger-install-apache2-module

    # Paste in from passenger install script

    # /etc/apache2/mods-available/passenger.load
    LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p286/gems/passenger-3.0.18/ext/apache2/mod_passenger.so

    # /etc/apache2/mods-available/passenger.conf
    <IfModule passenger_module>
     PassengerRoot /usr/local/rvm/gems/ruby-1.9.3-p286/gems/passenger-3.0.18
     PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.3-p286/ruby
    </IfModule>

    sudo a2enmod passenger

#### Set up virtual host

    # /etc/apache2/sites-available/alm
    <VirtualHost *>
      ServerName EXAMPLE.ORG
      ServerAdmin EXAMPLE@EXAMPLE.ORG
      ErrorLog /var/log/apache2/error_alm.log

      DocumentRoot /var/www/alm/current/public

      <Directory />
        Options FollowSymLinks
        AllowOverride All
      </Directory>

      <Directory /var/www/alm/current/public>
        Options -Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        Allow from all
      </Directory>

      # Important for ALM: keeps Apache from messing up encoded embedded slashes in DOIs
      AllowEncodedSlashes On
  
      # Deflate
      AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml application/xml application/xhtml+xml text/javascript
      BrowserMatch ^Mozilla/4 gzip-only-text/html
      BrowserMatch ^Mozilla/4.0[678] no-gzip
      BrowserMatch \bMSIE !no-gzip !gzip-only-text/html
    </VirtualHost>

    sudo a2ensite alm
    sudo service apache2 reload

#### Install Javascript

    sudo apt-get install nodejs nodejs-dev

#### Install Bundler
Bundler is a tool to manage dependencies of Ruby applications: http://gembundler.com

    rvmsudo gem install bundler

_This concludes the server installation. The following steps are done on your development machine._

#### Setup Capistrano
Capistrano is a deployment automation tool: http://capistranorb.com
On your development machine, install Capistrano

    rvmsudo gem install capistrano
    rvmsudo gem install rvm-capistrano
    
**Go to project root, then enable Capistrano**

    cd alm
    capify .

**Edit deployment configuration**

    # config/deploy.rb
    require "bundler/capistrano"
    require "rvm/capistrano"
    load 'deploy/assets'

    server "EXAMPLE.ORG", :app, :web, :db, :primary => true

    set :application, "alm"
    set :user, "www-data"
    set :group, "www-data"
    set :password, "EXAMPLE"
    set :deploy_to, "/var/www/#{application}"
    set :deploy_via, :remote_cache
    set :use_sudo, false

    set :scm, "git"
    set :repository, "git://github.com/articlemetrics/alm.git"
    set :branch, "master"

    set :bundle_without, [:development, :test]
   
    set :ruby_vm_type,      :mri        # :ree, :mri
    set :web_server_type,   :apache     # :apache, :nginx
    set :app_server_type,   :passenger  # :passenger, :mongrel
    set :db_server_type,    :mysql      # :mysql, :postgresql, :sqlite
    set :rvm_ruby_string, :local

    set :keep_releases, 5

    namespace :deploy do
      task :start do ; end
      task :stop do ; end
      task :restart, :roles => :app, :except => { :no_release => true } do
        run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
      end
    end

    before "deploy:assets:precompile" do
      run ["ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml",
       "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml",
       ].join(" && ")
    end

**Setup server**

    cap deploy:setup

**Configure Server**

    sudo mkdir /var/www/alm/shared/config
    sudo chown deploy:deploy /var/www/alm/shared/config

    # Add these two files from your development machine, add configuration
    /var/www/alm/shared/config/database.yml
    /var/www/alm/shared/config/settings.yml
    
    sudo chown deploy:deploy /var/www/alm/shared/config/database.yml
    sudo chown deploy:deploy /var/www/alm/shared/config/settings.yml

**Deploy your application**

    # only need on first deploy, database migrations and setup of sources
    cap deploy:migrations
    cap deploy:seed

## Usage

### Setup

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

### Adding articles

Articles can be added via the web interface (after logging in as admin), or via `rake doi_import <DOI_DUMP` (see below).

### Adding metrics

Metrics are automatically added in the background, using the [delayed_job](https://github.com/collectiveidea/delayed_job) queuing system. The results returned by external APIs are stored in CouchDB.

When we have to update the metrics for an article (determined by the staleness interval), a job is added to the background queue for that source. A delayed_job worker will then process this job in the background. We have to set up a queue and at least one worker for every source. In development mode this is done with `foreman`, using the configuration in `Procfile`:
    
    foreman start
    
In production mode the background processes run via the `upstart`system utility. The Chef/Vagrant setup has the upstart scripts already configured, otherwise this can be done (where USER is the user running the web server) via

    rvmsudo foreman export upstart /etc/init -a alm -f Procfile.prod -l /USER/log -u USER

Replace ``rvmsudo`` with ``sudo`` if you don't use RVM.

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