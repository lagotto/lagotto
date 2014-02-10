#
# Cookbook Name:: ms_dotnet2
# Recipe:: default
# Author:: Julian C. Dunn (<jdunn@getchef.com>)
#
# Copyright (C) 2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Attributes are only needed on Windows 2008 and below.
if node['platform_version'].to_f <= 6.0
  if node['kernel']['machine'] == 'x86_64'
    default['ms_dotnet2']['url'] = 'http://download.microsoft.com/download/c/6/e/c6e88215-0178-4c6c-b5f3-158ff77b1f38/NetFx20SP2_x64.exe'
    default['ms_dotnet2']['checksum'] = '430315c97c57ac158e7311bbdbb7130de3e88dcf5c450a25117c74403e558fbe'
  else
    default['ms_dotnet2']['url'] = 'http://download.microsoft.com/download/c/6/e/c6e88215-0178-4c6c-b5f3-158ff77b1f38/NetFx20SP2_x86.exe'
    default['ms_dotnet2']['checksum'] = '6e3f363366e7d0219b7cb269625a75d410a5c80d763cc3d73cf20841084e851f'
  end
end