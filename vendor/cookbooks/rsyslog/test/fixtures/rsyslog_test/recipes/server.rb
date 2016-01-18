require 'fileutils'
unless Dir.exist?("#{node['rsyslog']['config_prefix']}/49-rsyslog.d")
  FileUtils.mkdir("#{node['rsyslog']['config_prefix']}/49-rsyslog.d")
end

FileUtils.touch("#{node['rsyslog']['config_prefix']}/rsyslog.d/49-remote.conf")

include_recipe 'rsyslog::server'
