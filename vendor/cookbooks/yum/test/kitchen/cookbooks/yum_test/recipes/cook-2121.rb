#
# Cookbook Name:: yum_test
# Recipe:: cook-2121
#
# Copyright 2013, Opscode, Inc.
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

%w{add create}.each do |act|
  file "/etc/yum.repos.d/zenoss-#{act}.repo" do
    action :create
  end

  yum_repository "zenoss-#{act}" do
    description "Zenoss Stable repo"
    url "http://dev.zenoss.com/yum/stable/"
    key "RPM-GPG-KEY-zenoss"
    action act.to_sym
  end
end

yum_repository "cook-3025" do
  description "cook-3025"
  url "http://example.invalid"
  enabled 0
  make_cache false
  proxy "http://proxy.invalid:1234/path"
end
