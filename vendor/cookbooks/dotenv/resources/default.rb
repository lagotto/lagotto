actions :load
default_action :load

attribute :name, :kind_of => String, :name_attribute => true
attribute :dotenv, :kind_of => String, :default => 'default'
attribute :user, :kind_of => String, :default => node['ruby']['deploy_user']
attribute :group, :kind_of => String, :default => node['ruby']['deploy_group']
attribute :rails_env, :kind_of => String, :default => node['ruby']['rails_env']
attribute :servers, :kind_of => String, :default => 'www'
attribute :db_host, :kind_of => [String, NilClass]
