template '/etc/init.d/remote_syslog2' do
  source 'remote_syslog2.erb'
  mode '0755'
end

service 'remote_syslog2' do
  supports restart: true, status: true
  action [:start, :enable]
end