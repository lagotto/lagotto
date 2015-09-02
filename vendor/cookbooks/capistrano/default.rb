default['rails']['name'] = "app"
default['rails']['environment'] = 'development'

default['mysql']['remove_anonymous_users'] = true
default['mysql']['remove_test_database'] = true

default['nginx']['user'] = 'www-data'
default['nginx']['group'] = 'www-data'
default['nginx']['dir'] = '/etc/nginx'
default['nginx']['log_dir'] = '/var/log/nginx'
default['nginx']['worker_processes'] = 4
default['nginx']['worker_connections'] = 768
