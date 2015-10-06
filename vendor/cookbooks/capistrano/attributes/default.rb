default['ruby']['deploy_user'] = "vagrant"
default['ruby']['deploy_group'] = "vagrant"
default['ruby']['rails_env'] = "development"

default['application'] = "capistrano"

default['nodejs']['repo'] = 'https://deb.nodesource.com/node_0.12'

default['consul']['service_mode'] = 'cluster'
default['consul']['atlas_cluster'] = ENV['CONSUL_SERVERS'] || node['hostname']
default['consul']['atlas_token'] = ENV['ATLAS_TOKEN']

default['remote_syslog2']['config']['files'] = %W(
  /var/log/nginx/error_log
  /var/log/mongo/mongod.log
  /var/www/#{node['application']}/shared/log/app.log
)
default['remote_syslog2']['config']['destination']['host'] = ENV['PAPERTRAIL_HOST']
default['remote_syslog2']['config']['destination']['port'] = ENV['PAPERTRAIL_PORT']
default['remote_syslog2']['version'] = "v0.13"
default['remote_syslog2']['install']['download_file'] = "https://github.com/papertrail/remote_syslog2/releases/download/#{node['remote_syslog2']['version']}/remote_syslog_linux_amd64.tar.gz"
