if platform?('windows')
  src = node['nssm']['src']
  basename = src.slice(src.rindex('/') + 1, src.rindex('.') - src.rindex('/') - 1)

  log("nssm_basename=#{basename}")

  windows_zipfile Chef::Config[:file_cache_path] do
    checksum node['nssm']['sha256']
    source src
    action :unzip
    not_if { ::File.directory?("#{Chef::Config[:file_cache_path]}/#{basename}") }
  end

  system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'

  batch 'copy_nssm' do
    code <<-EOH
      xcopy "#{Chef::Config[:file_cache_path].tr('/', '\\')}\\#{basename}\\#{system}\\nssm.exe" \
"#{node['nssm']['install_location']}" /y
    EOH
    not_if { ::File.exist?("#{node['nssm']['install_location']}\\nssm.exe".gsub(/%[^%]+%/) { |m| ENV[m[1..-2]] }) }
  end
else
  log('NSSM can only be installed on Windows platforms!') { level :warn }
end
