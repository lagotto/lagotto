#
# Author:: Shawn Neal (<sneal@daptiv.com>)
# Cookbook Name:: seven_zip
# Provider:: archive
#
# Copyright:: 2013, Daptiv Solutions LLC
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

require 'fileutils'
require 'chef/mixin/shell_out'

include Chef::Mixin::ShellOut
include Windows::Helper

def whyrun_supported?
  true
end

action :extract do
  converge_by("Extract #{@new_resource.source} => #{@new_resource.path} (overwrite=#{@new_resource.overwrite})") do
    FileUtils.mkdir_p(@new_resource.path) unless Dir.exists?(@new_resource.path)
    local_source = cached_file(@new_resource.source, @new_resource.checksum)
    cmd = "#{seven_zip_exe} x"
    cmd << " -y" if @new_resource.overwrite
    cmd << " -o#{win_friendly_path(@new_resource.path)}"
    cmd << " #{local_source}"
    Chef::Log.debug(cmd)
    shell_out!(cmd)
  end
end


def seven_zip_exe()
  Chef::Log.debug("seven zip home: #{node['seven_zip']['home']}")
  win_friendly_path(::File.join(node['seven_zip']['home'], '7z.exe'))
end
