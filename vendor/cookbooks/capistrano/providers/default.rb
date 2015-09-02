def whyrun_supported?
  true
end

use_inline_resources

def load_current_resource
  @current_resource = Chef::Resource::Capistrano.new(new_resource.name)
end

action :deploy do
end

action :config do
  # create shared folders
  %W{ #{new_resource.name} #{new_resource.name}/shared #{new_resource.name}/shared/frontend #{new_resource.name}/shared/vendor #{new_resource.name}/shared/tmp #{new_resource.name}/shared/tmp/pids }.each do |dir|
    directory "/var/www/#{dir}" do
      owner new_resource.user
      group new_resource.group
      mode '0755'
      recursive true
    end
  end

  # symlink current folder
  link "/var/www/#{new_resource.name}/current" do
    to "/var/www/#{new_resource.name}/shared"
  end
end

action :bundle_install do
  run_context.include_recipe 'ruby'

  if ::File.exist?("/var/www/#{new_resource.name}/current/Gemfile")
    # make sure we can use the bundle command
    execute "bundle install" do
      user new_resource.user
      cwd "/var/www/#{new_resource.name}/shared"
      if new_resource.rails_env == "development"
        command "bundle config --delete without --no-deployment && bundle install --path vendor/bundle"
      else
        command "bundle install --path vendor/bundle --deployment --without development test"
      end
    end
  end
end

action :npm_install do
  run_context.include_recipe 'nodejs'

  # create directory for npm packages
  directory "/var/www/#{new_resource.name}/shared/frontend/node_modules" do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    action :create
  end

  # install npm packages, using information in package.json
  # we need to set $HOME because of a Chef bug: https://tickets.opscode.com/browse/CHEF-2517
  execute "npm install" do
    user new_resource.user
    cwd "/var/www/#{new_resource.name}/shared/frontend"
    environment ({ 'HOME' => ::Dir.home(new_resource.user), 'USER' => new_resource.user })
    action :run
  end
end

action :bower_install do
  run_context.include_recipe 'nodejs'
  run_context.include_recipe 'ruby'

  # provide Rakefile if it doesn't exist, e.g. during testing
  cookbook_file "Rakefile" do
    path "/var/www/#{new_resource.name}/shared/Rakefile"
    owner new_resource.user
    group new_resource.group
    cookbook "capistrano"
    action :create_if_missing
  end

  execute "bundle exec rake bower:install" do
    user new_resource.user
    environment ({ 'HOME' => ::Dir.home(new_resource.user), 'USER' => new_resource.user, 'RAILS_ENV' => new_resource.rails_env })
    cwd "/var/www/#{new_resource.name}/shared"
  end
end

action :consul_install do
  # install consul
  run_context.include_recipe 'consul'

  # monitor nginx service
  if node['recipes'].include?('passenger_nginx')
    consul_definition 'nginx' do
      type 'check'
      parameters(http: "http://#{node['fqdn']}:80", interval: '10s', timeout: '2s')
      notifies :reload, 'consul_service[consul]', :delayed
    end
  end
end

action :remote_syslog_install do
  # install remote_syslog
  run_context.include_recipe 'remote_syslog2' if node['remote_syslog2']['config']['destination']['host']
end

action :precompile_assets do
  run_context.include_recipe 'nodejs'
  run_context.include_recipe 'ruby'

  # provide Rakefile if it doesn't exist, e.g. during testing
  cookbook_file "Rakefile" do
    path "/var/www/#{new_resource.name}/current/Rakefile"
    owner new_resource.user
    group new_resource.group
    cookbook "capistrano"
    action :create_if_missing
  end

  execute "bundle exec rake assets:precompile" do
    user new_resource.user
    environment 'RAILS_ENV' => new_resource.rails_env
    cwd "/var/www/#{new_resource.name}/current"
    not_if { new_resource.rails_env == "development" }
  end
end

action :ember_build do
  run_context.include_recipe 'nodejs'
  run_context.include_recipe 'ruby'

  # provide Rakefile if it doesn't exist, e.g. during testing
  cookbook_file "Rakefile" do
    path "/var/www/#{new_resource.name}/current/Rakefile"
    owner new_resource.user
    group new_resource.group
    cookbook "capistrano"
    action :create_if_missing
  end

  execute "bundle exec rake ember:build" do
    user new_resource.user
    environment 'RAILS_ENV' => new_resource.rails_env
    cwd "/var/www/#{new_resource.name}/current"
  end
end

action :migrate do
  run_context.include_recipe 'ruby'

  # run database migrations
  execute "bundle exec rake db:migrate" do
    user new_resource.user
    environment 'RAILS_ENV' => new_resource.rails_env
    cwd "/var/www/#{new_resource.name}/current"
  end

  # load/reload seed data
  execute "bundle exec rake db:seed" do
    user new_resource.user
    environment 'RAILS_ENV' => new_resource.rails_env
    cwd "/var/www/#{new_resource.name}/current"
  end
end

action :restart do
  execute "restart" do
    cwd  "/var/www/#{new_resource.name}/current"
    command "mkdir -p tmp && touch tmp/restart.txt"
  end
end
