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
  # create folders
  if node['ruby']['enable_capistrano']
    dirs = %W{ #{new_resource.name} #{new_resource.name}/shared #{new_resource.name}/shared/frontend #{new_resource.name}/shared/vendor #{new_resource.name}/shared/tmp #{new_resource.name}/shared/tmp/pids }
  else
    dirs = %W{ #{new_resource.name} #{new_resource.name}/frontend #{new_resource.name}/vendor #{new_resource.name}/log #{new_resource.name}/tmp #{new_resource.name}/tmp/pids }
  end

  dirs.each do |dir|
    directory "/var/www/#{dir}" do
      owner new_resource.user
      group new_resource.group
      mode '0755'
      recursive true
    end
  end

  if node['ruby']['enable_capistrano']
    # symlink current folder
    link "/var/www/#{new_resource.name}/current" do
      to "/var/www/#{new_resource.name}/shared"
      owner new_resource.user
      group new_resource.group
      mode '0755'
    end
  end
end

action :bundle_install do
  run_context.include_recipe 'ruby'

  if node['ruby']['enable_capistrano']
    file = "/var/www/#{new_resource.name}/current/Gemfile"
  else
    file = "/var/www/#{new_resource.name}/Gemfile"
  end

  if ::File.exist?(file)
    # make sure we can use the bundle command
    if node['ruby']['enable_capistrano']
      dir = "/var/www/#{new_resource.name}/current"
    else
      dir = "/var/www/#{new_resource.name}"
    end

    execute "bundle install" do
      user new_resource.user
      cwd dir
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

  if node['ruby']['enable_capistrano']
    file = "/var/www/#{new_resource.name}/current/frontend/package.json"
  else
    file = "/var/www/#{new_resource.name}/frontend/package.json"
  end

  if ::File.exist?(file)
    # create directory for npm packages
    if node['ruby']['enable_capistrano']
      dir = "/var/www/#{new_resource.name}/current/frontend/node_modules"
    else
      dir = "/var/www/#{new_resource.name}/frontend/node_modules"
    end
    directory dir do
      owner new_resource.user
      group new_resource.group
      mode '0755'
      action :create
    end

    # install npm packages, using information in package.json
    # we need to set $HOME because of a Chef bug: https://tickets.opscode.com/browse/CHEF-2517
    execute "npm install" do
      user new_resource.user
      cwd "/var/www/#{new_resource.name}/frontend"
      environment ({ 'HOME' => ::Dir.home(new_resource.user), 'USER' => new_resource.user })
      action :run
    end
  end
end

action :consul_install do
  # install consul
  run_context.include_recipe 'consul'
end

action :rsyslog_config do
  # configure rsyslog
  if ENV['RSYSLOG_HOST']
    node.override['rsyslog']['server'] = false
    node.override['rsyslog']['server_ip'] = ENV['RSYSLOG_HOST']
    node.override['rsyslog']['port'] = ENV['RSYSLOG_PORT'] || 514
    node.override['rsyslog']['protocol'] = 'udp'

    run_context.include_recipe 'rsyslog::client'
  else
    node.override['rsyslog']['server'] = true

    run_context.include_recipe 'rsyslog::server'
  end
end

action :precompile_assets do
  run_context.include_recipe 'nodejs'
  run_context.include_recipe 'ruby'

  if node['ruby']['enable_capistrano']
    file = "/var/www/#{new_resource.name}/current/Gemfile"
  else
    file = "/var/www/#{new_resource.name}/Gemfile"
  end

  if ::File.exist?(file)
    # make sure we can use the bundle command
    if node['ruby']['enable_capistrano']
      dir = "/var/www/#{new_resource.name}/current"
    else
      dir = "/var/www/#{new_resource.name}"
    end

    execute "bundle exec rake assets:precompile" do
      user new_resource.user
      environment 'RAILS_ENV' => new_resource.rails_env
      cwd dir
      not_if { new_resource.rails_env == "development" }
    end
  end
end

action :migrate do
  run_context.include_recipe 'ruby'

  if node['ruby']['enable_capistrano']
    file = "/var/www/#{new_resource.name}/current/config/database.yml"
  else
    file = "/var/www/#{new_resource.name}/config/database.yml"
  end


  if ::File.exist?(file)
    # run database migrations
    if node['ruby']['enable_capistrano']
      dir = "/var/www/#{new_resource.name}/current"
    else
      dir = "/var/www/#{new_resource.name}"
    end

    execute "bundle exec rake db:migrate" do
      user new_resource.user
      environment 'RAILS_ENV' => new_resource.rails_env
      cwd dir
    end

    # load/reload seed data
    execute "bundle exec rake db:seed" do
      user new_resource.user
      environment 'RAILS_ENV' => new_resource.rails_env
      cwd dir
    end
  end
end

action :whenever do
  run_context.include_recipe 'ruby'

  if node['ruby']['enable_capistrano']
    file = "/var/www/#{new_resource.name}/current/config/schedule.rb"
  else
    file = "/var/www/#{new_resource.name}/config/schedule.rb"
  end


  if ::File.exist?(file)
    if node['ruby']['enable_capistrano']
      dir = "/var/www/#{new_resource.name}/current"
    else
      dir = "/var/www/#{new_resource.name}"
    end

    execute "whenever" do
      user new_resource.user
      environment 'RAILS_ENV' => new_resource.rails_env
      cwd  dir
      command "bundle exec whenever --update-crontab -i #{new_resource.name}"
    end
  end
end

action :restart do
  if node['ruby']['enable_capistrano']
    dir = "/var/www/#{new_resource.name}/current"
  else
    dir = "/var/www/#{new_resource.name}"
  end

  execute "restart" do
    cwd  dir
    command "mkdir -p tmp && touch tmp/restart.txt"
  end
end
