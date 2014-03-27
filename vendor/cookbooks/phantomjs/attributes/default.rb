#
# Cookbook Name:: phantomjs
# Attribute:: default
#
# Copyright 2012-2013, Seth Vargo (sethvargo@gmail.com)
# Copyright 2012-2013, CustomInk
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
#
# This is the default attributes file. Platform-specific attribute
# configurations are each contained in their {platform_name}.rb attribute
# file.
#

# The version of phantomjs to install
default['phantomjs']['version'] = '1.9.2'

# The list of packages to install
default['phantomjs']['packages'] = []

# The checksum of the tarball
default['phantomjs']['checksum'] = nil

# The default install method
default['phantomjs']['install_method'] = 'source'

# The default package name
default['phantomjs']['package_name'] = 'phantomjs'

# The src directory
default['phantomjs']['src_dir'] = '/usr/local/src'

# The base URL to download tarball from
default['phantomjs']['base_url'] = 'https://phantomjs.googlecode.com/files'

# The name of the tarball to download (this is automatically calculated from
# the phantomjs version and kernel type)
default['phantomjs']['basename'] = "phantomjs-#{node['phantomjs']['version']}-linux-#{node['kernel']['machine']}"
