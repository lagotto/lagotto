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

  require 'dotenv'

  if node['ruby']['enable_capistrano']
    filepath = "/var/www/#{new_resource.name}/shared/.env"
  else
    filepath = "/var/www/#{new_resource.name}/.env"
  end

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
