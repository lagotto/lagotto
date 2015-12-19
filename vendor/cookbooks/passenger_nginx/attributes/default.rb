default['nginx']['user'] = 'www-data'
default['nginx']['dir'] = '/etc/nginx'
default['nginx']['log_dir'] = '/var/log/nginx'
default['nginx']['worker_processes'] = 1
default['nginx']['worker_connections'] = 1024
default['nginx']['default_site_enabled'] = false
default['nginx']['behind_proxy'] = false
default['nginx']['rsyslog_server'] = '127.0.0.1'

default['ruby']['rails_env'] = "development"
default['ruby']['deploy_user'] = "vagrant"
default['ruby']['deploy_group'] = "vagrant"
default['ruby']['enable_capistrano'] = false
default['ruby']['merge_slashes_off'] = true
default['ruby']['api_only'] = false
default['ruby']['packages'] = %w{ curl git libmysqlclient-dev python-software-properties software-properties-common zlib1g-dev }
default['ruby']['packages'] += %w{ avahi-daemon libnss-mdns } if node['ruby']['rails_env'] != "production"

default['nodejs']['repo'] = 'https://deb.nodesource.com/node_0.12'
