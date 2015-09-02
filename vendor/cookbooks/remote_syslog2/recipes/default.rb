#
# Cookbook Name:: remote_syslog2
# Recipe:: default
#
# Copyright (C) 2014 Jeff Way
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'remote_syslog2::install'
include_recipe 'remote_syslog2::configure'
include_recipe 'remote_syslog2::service'