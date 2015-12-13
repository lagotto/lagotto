#
# Cookbook Name:: memcached
# resource:: instance
#
# Copyright 2009-2015, Chef Software, Inc.
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
property :user, String, default: nil
property :threads, [Integer, String], default: nil
property :max_object_size, String, default: '1m'
property :experimental_options, Array, default: []
property :ulimit, [Integer, String], default: nil
property :template_cookbook, String, default: 'memcached'

action :create do
  include_recipe 'runit'
  include_recipe 'memcached::package'

  runit_service instance_name do
    run_template_name 'memcached'
    default_logger true
    cookbook template_cookbook
    options(
      memory:  memory,
      port: port,
      udp_port: udp_port,
      listen: listen,
      maxconn: maxconn,
      user: service_user,
      threads: threads,
      max_object_size: max_object_size,
      experimental_options: experimental_options,
      ulimit: ulimit
    )
  end
end

action :remove do
  runit_service instance_name do
    action [:stop, :disable]
  end
end
