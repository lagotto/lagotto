require "yaml"

# config valid only for Capistrano 3.2
lock '3.2.1'

begin
  # Default value for default_env is {}
  # Load relevant ENV variables from application.yml
  CONFIG = YAML.load_file('application.yml')
  set :default_env, { 'WORKERS' => CONFIG['WORKERS'],
                      'SERVERS' => CONFIG['SERVERS'],
                      'DEPLOY_USER' => CONFIG['DEPLOY_USER'] }
rescue
  puts "File config/application.yml is missing. Please create file and try again."
  exit
end

set :application, 'lagotto'
set :repo_url, 'https://github.com/articlemetrics/lagotto.git'

# Default branch is :master
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/lagotto'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{ config/application.yml }

# Default value for linked_dirs is []
set :linked_dirs, %w{ bin log data tmp/pids tmp/sockets vendor/bundle public/files }

# Default value for keep_releases is 5
set :keep_releases, 5

# Install gems into shared/vendor/bundle
set :bundle_path, -> { shared_path.join('vendor/bundle') }

# Use system libraries for Nokogiri
set :bundle_env_variables, 'NOKOGIRI_USE_SYSTEM_LIBRARIES' => 1

# number of background workers
set :delayed_job_args, "-n #{ENV['WORKERS']}"

namespace :deploy do

  before :starting, "delayed_job:stop"

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :finishing, "deploy:cleanup"
  after :finishing, "delayed_job:start"
end
