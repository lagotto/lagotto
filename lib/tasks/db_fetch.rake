require 'yaml'
require 'erb'

namespace :db do
  desc "Download a copy of the remote production database and replace the local development database"
  task :fetch do
    raise "Can't fetch into production" if RAILS_ENV == "production"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
                
    puts "Recreating database"
    `sudo mysqladmin --force drop #{db_config[RAILS_ENV]["database"]} || set status 0`
    `sudo mysqladmin create #{db_config[RAILS_ENV]["database"]}`
    `echo \"grant all privileges on #{db_config[RAILS_ENV]["database"]}.* to \'#{db_config[RAILS_ENV]["username"]}\' identified by \'#{db_config[RAILS_ENV]["password"]}\';\" | sudo mysql mysql`
    `sudo mysqladmin flush-privileges`

    puts "Importing production data"
    `ssh selfamusementpark.com -p3386 "mysqldump -u#{db_config['production']["username"]} -p#{db_config['production']["password"]} --opt --skip-extended-insert plos_stage" | mysql -u#{db_config[RAILS_ENV]["username"]} -p#{db_config[RAILS_ENV]["password"]} #{db_config[RAILS_ENV]["database"]}`
    puts "Migrating"
    Rake::Task['db:migrate'].invoke
    if RAILS_ENV == "development"
      puts "Cloning structure to test"
      Rake::Task['db:test:clone'].invoke
    end
  end
end
