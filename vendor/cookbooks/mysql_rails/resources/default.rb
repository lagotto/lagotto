actions :create, :drop
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :rails_env, :kind_of => String, :default => node['ruby']['rails_env']
attribute :username, :kind_of => String, :default => node['mysql']['username']
attribute :password, :kind_of => String, :default => node['mysql']['password']
attribute :host, :kind_of => String, :default => node['mysql']['host']
attribute :root_password, :kind_of => String, :default => node['mysql']['server_root_password']
