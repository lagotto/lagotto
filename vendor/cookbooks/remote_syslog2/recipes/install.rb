install = node['remote_syslog2']['install']
bin_file = "#{install['bin_path']}/#{install['bin']}"

remote_file install['download_path'] do
  source install['download_file']
  mode '0644'
  not_if { ::File.exists?(bin_file) }
end

bash 'extract remote_syslog2' do
  cwd '/tmp'
  code <<-EOH
    mkdir -p #{install['extracted_path']}
    tar xzf #{install['download_path']} -C #{install['extract_path']}
    mv #{install['extracted_path']}/#{install['extracted_bin']} #{bin_file}
    rm -rf #{install['download_path']} #{install['extracted_path']}
  EOH
  not_if { ::File.exists?(bin_file) }
end

file bin_file do
  user 'root'
  group 'root'
  mode 0755
end