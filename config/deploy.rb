# config valid only for Capistrano 3.2
lock '3.3.5'

begin
  # make sure DOTENV is set
  ENV["DOTENV"] ||= "default"

  # load ENV variables from file specified by DOTENV
  # use .env with DOTENV=default
  filename = ENV["DOTENV"] == "default" ? ".env" : ".env.#{ENV['DOTENV']}"

  fail Errno::ENOENT unless File.exist?(File.expand_path("../../#{filename}", __FILE__))

  # load ENV variables from file specified by APP_ENV, fallback to .env
  require "dotenv"
  Dotenv.load! filename

  # make sure ENV variables required for capistrano are set
  fail ArgumentError if ENV['SERVERS'].to_s.empty? ||
                        ENV['DEPLOY_USER'].to_s.empty?
rescue Errno::ENOENT
  $stderr.puts "Please create file .env in the Rails root folder"
  exit
rescue LoadError
  $stderr.puts "Please install dotenv with \"gem install dotenv\""
  exit
rescue ArgumentError
  $stderr.puts "Please set SERVERS and DEPLOY_USER in the .env file"
  exit
end

# set :default_env, { 'DOTENV' => ENV["DOTENV"] }

set :application, ENV["APPLICATION"]
set :repo_url, 'https://github.com/articlemetrics/lagotto.git'
set :stage, ENV["STAGE"]

# Sidekiq
set :sidekiq_config, -> { File.join(current_path, 'config', 'sidekiq.yml') }
set :sidekiq_role, :db
set :pty, false

# Default branch is :master
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/lagotto'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
log_level = ENV["LOG_LEVEL"] ? ENV["LOG_LEVEL"].to_sym : :info
set :log_level, log_level

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# link .env file
#set :linked_files, %W{ #{filename} }
set :linked_files, %W{ .env }

# Default value for linked_dirs is []
set :linked_dirs, %w{ log data tmp/pids tmp/sockets vendor/bundle public/files }

# Default value for keep_releases is 5
set :keep_releases, 5

# Install gems into shared/vendor/bundle
set :bundle_path, -> { shared_path.join('vendor/bundle') }

# Use system libraries for Nokogiri
# set :bundle_env_variables, 'NOKOGIRI_USE_SYSTEM_LIBRARIES' => 1

set :rails_env, ENV['RAILS_ENV']

ENV['SERVERS'].split(",").each_with_index do |s, i|
  # only primary server has db role
  r = i > 0 ? %w(web app) : %w(web app db)

  server s, user: ENV['DEPLOY_USER'], roles: r
end

namespace :deploy do
  before :starting, "sidekiq:quiet"

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :finishing, "deploy:cleanup"
  after :finishing, "sidekiq:stop"
  after :finished, "sidekiq:start"
end
