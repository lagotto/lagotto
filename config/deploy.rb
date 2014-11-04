# config valid only for Capistrano 3.2
lock '3.2.1'

begin
  # make sure file .env exists
  fail Errno::ENOENT unless File.exist?(File.expand_path('../../.env', __FILE__))

  # load ENV variables from file specified by APP_ENV, fallback to .env
  require "dotenv"
  filename = ENV["APP_ENV"] ? ".env.#{ENV['APP_ENV']}" : ".env"
  Dotenv.load! filename

  # make sure ENV variables required for capistrano are set
  fail ArgumentError if ENV['WORKERS'].to_s.empty? ||
                        ENV['SERVERS'].to_s.empty? ||
                        ENV['DEPLOY_USER'].to_s.empty?
rescue Errno::ENOENT
  $stderr.puts "Please create file .env in the Rails root folder"
  exit
rescue LoadError
  $stderr.puts "Please install dotenv with \"gem install dotenv\""
  exit
rescue ArgumentError
  $stderr.puts "Please set WORKERS, SERVERS and DEPLOY_USER in the .env file"
  exit
end

set :application, ENV["APPLICATION"]
set :repo_url, 'https://github.com/articlemetrics/lagotto.git'
set :stage, ENV["STAGE"]

# Default branch is :master
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/lagotto'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# link .env file
set :linked_files, %W{ filename }

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
