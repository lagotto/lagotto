#
# Cookbook Name:: passenger_apache2
# Recipe:: package
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

unless(node['passenger']['package']['name'])
  raise 'Passenger package name must be defined!'
end

if(node['passenger']['apache_mpm'])
  Chef::Log.warn "Attribute `node['passenger']['apache_mpm']` is not effective in package based installs"
end

package node['passenger']['package']['name'] do
  version node['passenger']['package']['version']
end

apache_module 'passenger'
