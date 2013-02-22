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
else
  raise "Unsupported passenger installation method requested: #{node['passenger']['install_method']}. Supported: source or package."
end

if(node['passenger']['manage_module_conf'])
  include_recipe 'passenger_apache2::mod_rails'
end

apache_module 'passenger' do
  module_path node['passenger']['module_path']
end
