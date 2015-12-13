# install and configure dependencies
include_recipe "apt"
include_recipe "nodejs"

execute "apt-get update" do
  action :nothing
end

# add Phusion PPA for Nginx compiled with Passenger
apt_repository "phusion-passenger-#{node['lsb']['codename']}" do
  uri          "https://oss-binaries.phusionpassenger.com/apt/passenger"
  distribution node['lsb']['codename']
  components   ["main"]
  keyserver    "keyserver.ubuntu.com"
  key          "561F9B9CAC40B2F7"
  action       :add
  notifies     :run, "execute[apt-get update]", :immediately
end

# install nginx with passenger
%w{ nginx-full passenger }.each do |pkg|
  package pkg do
    options "-y --force-yes"
    action :install
  end
end

# nginx configuration
template 'nginx.conf' do
  path   "#{node['nginx']['dir']}/nginx.conf"
  source 'nginx.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  notifies :reload, 'service[nginx]'
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :nothing
end
