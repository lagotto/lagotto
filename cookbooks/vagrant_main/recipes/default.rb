require_recipe "apt"
require_recipe "build-essential"
require_recipe "git"

require_recipe "apache2"
require_recipe "passenger_apache2::mod_rails"

require 'securerandom'
require 'yaml'

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# Install more recent version of chef gem
gem_package "chef" do
  version "0.10.10"
  action :install
end

# Install bundler gem and run bundle command
gem_package "bundler" do
  version "1.1.3"
  action :install
end
bash "run bundle install in app directory" do
  cwd "/vagrant"
  code "bundle install"
end

# Generate new password for MySQL root unless it has already been stored in database.yml 
# This has to go before the require_recipe for mysql::server
if File.exists? "/vagrant/config/database.yml"
  stored_password = YAML.load_file("/vagrant/config/database.yml")["test"]["password"]
  node.set_unless['mysql']['server_root_password'] = stored_password
else
  node.set_unless['mysql']['server_root_password'] = secure_password  
end

require_recipe "mysql::server"

# create new database.yml
template "/vagrant/config/database.yml" do
  source 'database.yml.erb'
  owner 'root'
  group 'root'
  mode 0644
end

# Generate new password for MySQL root unless it has already been stored in database.yml 
# This has to go before the require_recipe for mysql::server
if File.exists? "/vagrant/config/settings.yml"
  settings = YAML.load_file("/vagrant/config/database.yml")["defaults"]
  node.set_unless['app']['key'] = settings["rest_auth_site_key"]
  node.set_unless['app']['secret'] = settings["session_secret"]
else
  node.set_unless['app']['key'] = SecureRandom.hex(30)
  node.set_unless['app']['secret'] = SecureRandom.hex(30)
  
end

# create new settings.yml
template "/vagrant/config/settings.yml" do

  source 'settings.yml.erb'
  owner 'root'
  group 'root'
  mode 0644
end

# Create default database and run migrations
bash "RAILS_ENV=#{node[:rails][:environment]} rake db:setup" do
  cwd "/vagrant"
  code "RAILS_ENV=#{node[:rails][:environment]} rake db:setup"
end

execute "disable-default-site" do
  command "sudo a2dissite default"
  notifies :reload, resources(:service => "apache2"), :delayed
end

web_app "default" do
  docroot "/vagrant/public"
  template "default.erb"
  notifies :reload, resources(:service => "apache2"), :delayed
end