def whyrun_supported?
  true
end

use_inline_resources

def load_current_resource
  @current_resource = Chef::Resource::PassengerNginx.new(new_resource.name)
end

action :config do
  run_context.include_recipe "passenger_nginx"

  service 'nginx' do
    supports :status => true, :restart => true, :reload => true
    action   :nothing
  end

  # optionally delete default configuration file
  file "#{node['nginx']['dir']}/sites-enabled/default" do
    only_if { new_resource.default_server }
    action :delete
    notifies :reload, 'service[nginx]'
  end

  # create application root folder and set permissions
  if node['ruby']['enable_capistrano']
    folders = %W{ #{new_resource.name} #{new_resource.name}/shared #{new_resource.name}/shared/public }
  else
    folders = %W{ #{new_resource.name} #{new_resource.name}/public }
  end

  folders.each do |dir|
    directory "/var/www/#{dir}" do
      owner new_resource.user
      group new_resource.group
      mode '0755'
      recursive true
    end
  end

  # we symlink from the shared folder instead of creating the root folder directly
  if node['ruby']['enable_capistrano']
    link "/var/www/#{new_resource.name}/current" do
      to "/var/www/#{new_resource.name}/shared"
    end
  end

  template "#{node['nginx']['dir']}/sites-enabled/#{new_resource.name}.conf" do
    source "app.conf.erb"
    owner 'root'
    group 'root'
    mode '0644'
    cookbook 'passenger_nginx'
    variables(
      :application    => new_resource.name,
      :rails_env      => new_resource.rails_env,
      :default_server => new_resource.default_server
    )
    notifies :reload, 'service[nginx]'
  end
end

action :cleanup do
  file "#{node['nginx']['dir']}/sites-enabled/#{new_resource.name}.conf" do
    action :delete
    notifies :reload, 'service[nginx]'
  end
end
