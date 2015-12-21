# install and configure dependencies
node.set['set_fqdn'] = ENV['HOSTNAME']
include_recipe "hostnames::default"
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

if ENV['RSYSLOG_HOST']
  node.override['nginx']['rsyslog_server']  = "#{ENV['RSYSLOG_HOST']}:#{ENV['RSYSLOG_PORT']}"
end

# nginx configuration
template 'nginx.conf' do
  path   "#{node['nginx']['dir']}/nginx.conf"
  source 'nginx.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  cookbook 'passenger_nginx'
  variables(
    :rsyslog_server => node['nginx']['rsyslog_server']
  )
  notifies :reload, 'service[nginx]'
end

# add conf directory
directory "#{node['nginx']['dir']}/include.d" do
  owner 'root'
  group 'root'
  mode '0755'
end

# enable CORS
template 'cors.conf' do
  path   "#{node['nginx']['dir']}/include.d/cors.conf"
  source 'cors.conf'
  owner  'root'
  group  'root'
  mode   '0644'
  cookbook 'passenger_nginx'
  notifies :reload, 'service[nginx]'
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :nothing
end
