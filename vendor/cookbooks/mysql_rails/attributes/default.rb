default['ruby']['rails_env'] = "development"

default['mysql']['username'] = "root"
default['mysql']['password'] = node['mysql']['server_root_password']
default['mysql']['host'] = "127.0.0.1"
default['mysql']['enable_utf8'] = true
