#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: couchdb
# Attributes:: couchdb
#
# Copyright 2010, Opscode, Inc
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

default['couch_db']['src_checksum']   = "b54e643f3ca5f046cfd2f329a001efeaae8a3094365fa6c1cb5dcf68c1b25ccd"
default['couch_db']['src_version']    = "1.2.1"
default['couch_db']['src_mirror']     = "http://archive.apache.org/dist/couchdb/#{node['couch_db']['src_version']}/apache-couchdb-#{node['couch_db']['src_version']}.tar.gz"
default['couch_db']['install_erlang'] = true

# Attributes below are used to configure your couchdb instance.
# These defaults were extracted from this url:
#  http://wiki.apache.org/couchdb/Configurationfile_couch.ini
#
# Configuration file is now removed in favor of dynamic
# generation.

default['couch_db']['config']['couchdb']['max_document_size'] = 4294967296 # In bytes (4 GB)
default['couch_db']['config']['couchdb']['max_attachment_chunk_size'] = 4294967296 # In bytes (4 GB)
default['couch_db']['config']['couchdb']['os_process_timeout'] = 5000 # In ms (5 seconds)
default['couch_db']['config']['couchdb']['max_dbs_open'] = 100
default['couch_db']['config']['couchdb']['delayed_commits'] = true
default['couch_db']['config']['couchdb']['batch_save_size'] = 1000
default['couch_db']['config']['couchdb']['batch_save_interval'] = 1000  # In ms (1 second)

default['couch_db']['config']['httpd']['port'] = 5984
default['couch_db']['config']['httpd']['bind_address'] = "127.0.0.1"

default['couch_db']['config']['log']['level'] = "info"
