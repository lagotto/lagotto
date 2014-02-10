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

case node['platform']
when 'windows'

  require 'chef/win32/version'
  windows_version = Chef::ReservedNames::Win32::Version.new

  if (windows_version.windows_server_2008_r2? || windows_version.windows_7?) && windows_version.core?
    # Windows Server 2008 R2 Core does not come with .NET or Powershell 2.0 enabled

    windows_feature 'NetFx2-ServerCore' do
      action :install
    end
    windows_feature 'NetFx2-ServerCore-WOW64' do
      action :install
      only_if { node['kernel']['machine'] == 'x86_64' }
    end

  elsif windows_version.windows_server_2008? || windows_version.windows_server_2003_r2? ||
      windows_version.windows_server_2003? || windows_version.windows_xp?

    if windows_version.windows_server_2008?
      # Windows PowerShell 2.0 requires version 2.0 of the common language runtime (CLR).
      # CLR 2.0 is included with the Microsoft .NET Framework versions 2.0, 3.0, or 3.5 with Service Pack 1.
      windows_feature 'NET-Framework-Core' do
        action :install
      end
    else
      # XP, 2003 and 2003R2 don't have DISM or servermanagercmd, so download .NET 2.0 manually
      windows_package 'Microsoft .NET Framework 2.0 Service Pack 2' do
        source node['ms_dotnet2']['url']
        checksum node['ms_dotnet2']['checksum']
        installer_type :custom
        options '/quiet /norestart'
        action :install
      end
    end
  else
    log '.NET Framework 2.0 is already enabled on this version of Windows' do
      level :warn
    end
  end
else
  log '.NET Framework 2.0 cannot be installed on platforms other than Windows' do
    level :warn
  end
end