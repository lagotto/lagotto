#
# Cookbook Name:: passenger_apache2
# Recipe:: default
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Joshua Sierles (<joshua@37signals.com>)
# Author:: Michael Hale (<mikehale@gmail.com>)
#
# Copyright:: 2009, Opscode, Inc
# Copyright:: 2009, 37signals
# Coprighty:: 2009, Michael Hale
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'apache2'

case node['passenger']['install_method']
when 'source'
  include_recipe 'passenger_apache2::source'
when 'package'
  include_recipe 'passenger_apache2::package'
  node.set['passenger']['manage_module_conf'] = false
else
  raise "Unsupported passenger installation method requested: #{node['passenger']['install_method']}. Supported: source or package."
end

if(node['passenger']['manage_module_conf'])
  include_recipe 'passenger_apache2::mod_rails'
end

ruby_block "reload_ruby" do
  block do
    # Only available on Chef 10.x, but only needed there anyway
    if node.respond_to?(:load_attribute_by_short_filename)
      node.load_attribute_by_short_filename('default', 'passenger_apache2')
    end
  end

  action :nothing
  subscribes :create, "ohai[reload]", :immediately
end
