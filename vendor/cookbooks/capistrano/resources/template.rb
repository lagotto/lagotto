actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :application, :kind_of => String, :default => "app"
attribute :source, :kind_of => String, :default => ""
attribute :user, :kind_of => String, :default => node['ruby']['deploy_user']
attribute :group, :kind_of => String, :default => node['ruby']['deploy_group']
attribute :params, :kind_of => Hash, :default => {}
