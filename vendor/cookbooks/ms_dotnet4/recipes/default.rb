#
# Cookbook Name:: ms_dotnet4
# Recipe:: default
#
# Copyright 2012, Webtrends, Inc.
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

if platform?('windows')
  if win_version.windows_server_2008? || win_version.windows_server_2008_r2? || win_version.windows_7? || win_version.windows_vista?
    unless File.exists?('C:/Windows/Microsoft.NET/Framework/v4.0.30319')
      windows_package 'Microsoft .NET Framework 4 Client Profile' do
        source node['ms_dotnet4']['http_url']
        installer_type :custom
        options '/quiet /norestart'
        action :install
      end
    end
  elsif win_version.windows_server_2003_r2? || win_version.windows_server_2003? || win_version.windows_xp?
    Chef::Log.warn('The .NET 4.0 Chef recipe currently only supports Windows Vista, 7, 2008, and 2008 R2.')
  end
else
  Chef::Log.warn('Microsoft .NET Framework 4.0 can only be installed on the Windows platform.')
end
