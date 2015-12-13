#
# Cookbook Name:: golang
# Recipe:: default
#
# Copyright 2013, Alexander Rozhnov
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

node.default['go']['platform'] = node['kernel']['machine'] =~ /i.86/ ? '386' : 'amd64'
node.default['go']['filename'] = "go#{node['go']['version']}.#{node['os']}-#{node['go']['platform']}.tar.gz"
node.default['go']['url'] = "http://golang.org/dl/#{node['go']['filename']}"

bash "install-golang" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    rm -rf go
    rm -rf #{node['go']['install_dir']}/go
    tar -C #{node['go']['install_dir']} -xzf #{node['go']['filename']}
  EOH
  not_if { node['go']['from_source'] }
  action :nothing
end

bash "build-golang" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    rm -rf go
    rm -rf #{node['go']['install_dir']}/go
    tar -C #{node['go']['install_dir']} -xzf #{node['go']['filename']}
    cd #{node['go']['install_dir']}/go/src
    mkdir -p $GOBIN
    ./#{node['go']['source_method']}
  EOH
  environment ({
    'GOROOT' => "#{node['go']['install_dir']}/go",
    'GOBIN'  => '$GOROOT/bin',
    'GOOS'   => node['go']['os'],
    'GOARCH' => node['go']['arch'],
    'GOARM'  => node['go']['arm']
  })
  only_if { node['go']['from_source'] }
  action :nothing
end

if node['go']['from_source']
  case node["platform"]
  when 'debian', 'ubuntu'
    packages = %w(build-essential)
  when 'redhat', 'centos', 'fedora'
    packages = %w(gcc glibc-devel)
  end
  packages.each do |dev_package|
    package dev_package do
      action :install
    end
  end
end

remote_file File.join(Chef::Config[:file_cache_path], node['go']['filename']) do
  source node['go']['url']
  owner 'root'
  mode 0644
  notifies :run, 'bash[install-golang]', :immediately
  notifies :run, 'bash[build-golang]', :immediately
  not_if "#{node['go']['install_dir']}/go/bin/go version | grep \"go#{node['go']['version']} \""
end

directory node['go']['gopath'] do
  action :create
  recursive true
  owner node['go']['owner']
  group node['go']['group']
  mode node['go']['mode']
end

directory node['go']['gobin'] do
  action :create
  recursive true
  owner node['go']['owner']
  group node['go']['group']
  mode node['go']['mode']
end

template "/etc/profile.d/golang.sh" do
  source "golang.sh.erb"
  owner 'root'
  group 'root'
  mode 0755
end

if node['go']['scm']
  %w(git mercurial bzr).each do |scm|
    package scm
  end
end
