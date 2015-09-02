include_recipe "apt"

execute "apt-get update" do
  action :nothing
end

apt_repository "brightbox-ruby-ng-#{node['lsb']['codename']}" do
  uri          "http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu"
  distribution node['lsb']['codename']
  components   ["main"]
  keyserver    "keyserver.ubuntu.com"
  key          "C3173AA6"
  action       :add
  notifies     :run, "execute[apt-get update]", :immediately
end

# install Ruby
package "ruby#{node['ruby']['version']}" do
  action :install
end

package "ruby#{node['ruby']['version']}-dev" do
  only_if { node['ruby']['install_dev_package'] }
  action :install
end

# install libraries required by Ruby gems
node['ruby']['packages'].each do |pkg|
  package pkg do
    action :install
  end
end

# install system gems, using the freshly installed Ruby
node['ruby']['gems'].each do |gem|
  gem_package gem do
    gem_binary "/usr/bin/gem"
    action :install
  end
end
