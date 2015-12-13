def whyrun_supported?
  true
end

use_inline_resources

def load_current_resource
  @current_resource = Chef::Resource::Dotenv.new(new_resource.name)
end

action :load do
  chef_gem "dotenv" do
    compile_time true if respond_to?(:compile_time)
    action :install
  end

  # find file specified by dotenv atrribute
  # use .env when dotenv is "default"
  require 'dotenv'
  ENV["DOTENV"] = new_resource.dotenv
  filename = new_resource.dotenv == "default" ? ".env" : ".env.#{new_resource.dotenv}"

  if node['ruby']['enable_capistrano']
    filepath = "/var/www/#{new_resource.name}/shared/#{filename}"
  else
    filepath = "/var/www/#{new_resource.name}/#{filename}"
  end

  # load ENV variables from file specified by dotenv atrribute
  # otherwise set some ENV variables
  if ::File.exist?(filepath)
    ::Dotenv.load! filepath
  else
    ENV["APPLICATION"] = new_resource.name
    ENV["DEPLOY_USER"] = new_resource.user
    ENV["DEPLOY_GROUP"] = new_resource.group
    ENV["RAILS_ENV"] = new_resource.rails_env
    ENV["SERVERS"] = new_resource.servers
    ENV['DB_HOST'] = new_resource.db_host
  end
end
