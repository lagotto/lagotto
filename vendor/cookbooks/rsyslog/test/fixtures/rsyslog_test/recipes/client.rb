require 'fileutils'
unless Dir.exist?("#{node['rsyslog']['config_prefix']}/rsyslog.d")
  FileUtils.mkdir("#{node['rsyslog']['config_prefix']}/rsyslog.d")
end

FileUtils.touch("#{node['rsyslog']['config_prefix']}/rsyslog.d/server.conf")

include_recipe 'rsyslog::client'
