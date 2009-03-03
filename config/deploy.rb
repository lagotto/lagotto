instance = 'stage' # ENV["SITE"]
action_given = $*.any? {|arg| arg[0] != ?-}
if action_given
  abort "Must specify SITE=[production|stage] before cap on the command line'" \
    unless %w{production stage}.include?(instance)

  server = "selfamusementpark.com"
  role :app, server
  role :web, server
  role :db,  server, :primary => true

  set :application, 'plos'
  set :rails_env, instance
  set :deploy_to, "/var/rails/#{application}.#{instance}"
  set :repository, "svn+ssh://cvsuser@svn.plos.org/alm/tags/#{instance}"
  set :scm, :subversion
  set :keep_releases, 5

  set :owner, 'www-data'
  set :runner, 'root'
  set :user, 'stearns'
  # ssh_options[:verbose] = :debug

  set :migrate_target, :current
end

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Fetch images and database from production"
  task :get_production_data, :roles => :app do
    # No 'production' to get data from yet
    #run "cd #{release_path} && sudo rake RAILS_ENV=#{rails_env} SHARED_PATH=#{shared_path} fetch" unless instance == 'production'
  end

  desc "Tweak the deployed files (add database.yml, etc)"
  task :tweak_deployed_files do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
    run "ln -nfs #{shared_path}/config/initializers/site_keys.rb #{release_path}/config/initializers/site_keys.rb" 
  end
  after "deploy:update_code", "deploy:tweak_deployed_files"

  desc "Fix file ownership"
  task :fix_file_ownership do
    # Make sure our logs are group-writable (for now)
    run "sudo touch #{shared_path}/log/#{rails_env}.log"
    run "sudo chmod 0666 #{shared_path}/log/#{rails_env}.log"

    # Make sure everything is owned by the right user
    run "sudo chown #{owner}:#{owner} -R #{current_path}/"
    run "sudo chown #{owner}:#{owner} -R #{shared_path}"
  end

  desc "Set up extra shared directories"
  task :setup_extra_shared do
    run "mkdir -p #{shared_path}/config #{shared_path}/public/javascripts"
  end
  after "deploy:setup", "deploy:setup_extra_shared"

  desc "Update test instance data, fix ownership, & migrate"
  task :fetch_fix_ownership_and_migrate do
    deploy.get_production_data
    deploy.fix_file_ownership
    deploy.migrate
    deploy.fix_file_ownership
  end
  before "deploy:start", "deploy:fetch_fix_ownership_and_migrate"
  before "deploy:restart", "deploy:fetch_fix_ownership_and_migrate"

  desc "Restart Workling daemon"
  task :restart_workling_daemon do
    run "RAILS_ENV=#{rails_env} sudo #{current_path}/script/workling_client stop || set status 0"
    run "RAILS_ENV=#{rails_env} #{current_path}/script/workling_client start"
  end
  after "deploy:start", "deploy:restart_workling_daemon"
  after "deploy:restart", "deploy:restart_workling_daemon"
end

after "deploy:restart" do
  deploy.cleanup
end unless instance == 'production' # for now, don't clean up production.
