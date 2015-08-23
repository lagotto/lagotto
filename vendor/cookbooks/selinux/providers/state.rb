#
# Cookbook Name:: selinux
# Provider:: default
#
# Copyright 2011, Chef Software, Inc.
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

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

action :enforcing do
  unless @current_resource.state == "enforcing"
    execute "selinux-enforcing" do
      not_if "getenforce | grep -qx 'Enforcing'"
      command "setenforce 1"
    end
    se_template = render_selinux_template("enforcing")
  end
end

action :disabled do
  unless @current_resource.state == "disabled"
    execute "selinux-disabled" do
      only_if "selinuxenabled"
      command "setenforce 0"
    end
    se_template = render_selinux_template("disabled")
  end
end

action :permissive do
  unless @current_resource.state == "permissive" || @current_resource.state == "disabled"
    execute "selinux-permissive" do
      not_if "getenforce | egrep -qx 'Permissive|Disabled'"
      command "setenforce 0"
    end
    se_template = render_selinux_template("permissive")
  end
end

def load_current_resource
  @current_resource = Chef::Resource::SelinuxState.new(new_resource.name)
  s = shell_out("getenforce")
  @current_resource.state(s.stdout.chomp.downcase)
end

def render_selinux_template(state)
  template "#{state} selinux config" do
    path "/etc/selinux/config"
    source "sysconfig/selinux.erb"
    cookbook "selinux"
    if state == 'permissive'
      not_if "getenforce | grep -qx 'Disabled'"
    end
    variables(
      :selinux => state,
      :selinuxtype => "targeted"
    )
  end
end
