file node['remote_syslog2']['config_file'] do
  content node['remote_syslog2']['config'].to_hash.to_yaml
  mode '0644'
  notifies :restart, 'service[remote_syslog2]', :delayed
end