def whyrun_supported?
  true
end

use_inline_resources

def load_current_resource
  @current_resource = Chef::Resource::MysqlRails.new(new_resource.name)
end

action :create do
  # set mysql root password
  node.set['mysql']['server_root_password'] = new_resource.root_password

  run_context.include_recipe 'ruby::empty'
  run_context.include_recipe 'mysql::server'
  run_context.include_recipe 'database::mysql'

  # create database
  mysql_database new_resource.name do
    connection mysql_connection_info
    action :create
  end

  # create database user with all privileges
  mysql_database_user new_resource.username do
    connection mysql_connection_info
    password   new_resource.password
    host       new_resource.host
    privileges [:all]
    action     [:create, :grant]
  end
end

action :drop do
  mysql_database "#{new_resource.name}_#{new_resource.rails_env}" do
    connection mysql_connection_info
    action :drop
  end
end

def mysql_connection_info
  { host:      new_resource.host,
    username:  'root',
    password:  new_resource.root_password }
end
