#
# Cookbook Name:: memcached
# resource:: instance
#
# Copyright 2009-2016, Chef Software, Inc.
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
#

property :instance_name, String, name_attribute: true
property :memory, [Integer, String], default: 64
property :port, [Integer, String], default: 11_211
property :udp_port, [Integer, String], default: 11_211
property :listen, String, default: '0.0.0.0'
property :maxconn, [Integer, String], default: 1024
property :user, String
property :threads, [Integer, String]
property :max_object_size, String, default: '1m'
property :experimental_options, Array, default: []
property :ulimit, [Integer, String]
property :template_cookbook, String, default: 'memcached'
property :disable_default_instance, [TrueClass, FalseClass], default: true

action :create do
  include_recipe 'runit'
  include_recipe 'memcached::package'

  # Disable the default memcached service to avoid port conflicts + wasted memory
  service 'disable default memcached' do
    service_name 'memcached'
    action [:stop, :disable]
    only_if { new_resource.disable_default_instance }
  end

  runit_service new_resource.instance_name do
    run_template_name 'memcached'
    default_logger true
    cookbook new_resource.template_cookbook
    options(
      memory:  new_resource.memory,
      port: new_resource.port,
      udp_port: new_resource.udp_port,
      listen: new_resource.listen,
      maxconn: new_resource.maxconn,
      user: service_user,
      threads: new_resource.threads,
      max_object_size: new_resource.max_object_size,
      experimental_options: new_resource.experimental_options,
      ulimit: new_resource.ulimit
    )
  end
end

action :remove do
  runit_service new_resource.instance_name do
    action [:stop, :disable]
  end
end
