# config valid only for Capistrano 3.2
lock '3.2.1'

set :application, 'lagotto'
set :repo_url, 'https://github.com/articlemetrics/lagotto.git'

# Default branch is :master
set :branch, 'master'

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/alm'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{ config/database.yml config/settings.yml }

# Default value for linked_dirs is []
set :linked_dirs, %w{ bin log data tmp/pids tmp/sockets vendor/bundle public/files }

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# Install gems into shared/vendor/bundle
set :bundle_path, -> { shared_path.join('vendor/bundle') }

# Use system libraries for Nokogiri
set :bundle_env_variables, 'NOKOGIRI_USE_SYSTEM_LIBRARIES' => 1

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
