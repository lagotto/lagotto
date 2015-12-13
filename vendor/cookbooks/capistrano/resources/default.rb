actions :deploy, :config, :bundle_install, :npm_install, :consul_install, :precompile_assets, :migrate, :whenever, :restart
default_action :deploy

attribute :name, :kind_of => String, :name_attribute => true
attribute :user, :kind_of => String, :default => node['ruby']['deploy_user']
attribute :group, :kind_of => String, :default => node['ruby']['deploy_group']
attribute :rails_env, :kind_of => String, :default => node['ruby']['rails_env']
