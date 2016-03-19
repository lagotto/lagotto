#
# Cookbook: rubyzip
# License: Apache 2.0
#
# Copyright 2010, VMware, Inc.
# Copyright 2011-2015, Chef Software, Inc.
# Copyright 2016, Bloomberg Finance L.P.
#

if Chef::Resource::ChefGem.instance_methods(false).include?(:compile_time)
  chef_gem 'rubyzip' do
    version node['rubyzip']['version']
    compile_time true
  end
else
  chef_gem 'rubyzip' do
    version node['rubyzip']['version']
    action :nothing
  end.run_action(:install)
end

require 'zip'
