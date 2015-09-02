# load .env configuration file with ENV variables
# copy configuration file to shared folder
dotenv node["application"] do
  dotenv          node["dotenv"]
  action          :nothing
end.run_action(:load)

# install and configure dependencies
include_recipe "apt"
include_recipe "redisio"
include_recipe "redisio::enable"
include_recipe "memcached"
include_recipe "postfix"
include_recipe "nodejs"

# optionall install mysql and create database
if ENV['DB_HOST'] == "localhost"
  mysql_rails ENV['DB_NAME'] do
    username        ENV['DB_USERNAME']
    password        ENV['DB_PASSWORD']
    host            ENV['DB_HOST']
    root_password   ENV['DB_ROOT_PASSWORD']
    action          :create
  end
end

# install nginx and create configuration file and application root
passenger_nginx node["application"] do
  user            ENV['DEPLOY_USER']
  group           ENV['DEPLOY_GROUP']
  rails_env       ENV['RAILS_ENV']
  action          :config
end

# create required files and folders, and deploy application
capistrano node["application"] do
  user            ENV['DEPLOY_USER']
  group           ENV['DEPLOY_GROUP']
  rails_env       ENV['RAILS_ENV']
  action          [:config, :bundle_install, :npm_install, :consul_install, :precompile_assets, :migrate, :restart]
end
