require 'win32ole' if RUBY_PLATFORM =~ /mswin|mingw32|windows/

use_inline_resources

def execute_wmi_query(wmi_query)
  wmi = ::WIN32OLE.connect('winmgmts://')
  result = wmi.ExecQuery(wmi_query)
  return nil unless result.each.count > 0
  result
end

def service_installed?(servicename)
  !execute_wmi_query("select * from Win32_Service where name = '#{servicename}'").nil?
end

def install_nssm
  recipe_eval do
    run_context.include_recipe 'nssm::default'
  end unless run_context.loaded_recipe? 'nssm::default'
end

def nssm_exe
  "#{node['nssm']['install_location']}\\nssm.exe"
end

action :install do
  if platform?('windows')
    install_nssm

    service_installed = service_installed?(new_resource.servicename)

    batch "Install #{new_resource.servicename} service" do
      code <<-EOH
        #{nssm_exe} install "#{new_resource.servicename}" "#{new_resource.program}" #{new_resource.args}
      EOH
      not_if { service_installed }
    end

    new_resource.params.map do |k, v|
      batch "Set parameter #{k} #{v}" do
        code <<-EOH
          #{nssm_exe} set "#{new_resource.servicename}" #{k} #{v}
        EOH
      end
    end unless service_installed

    if new_resource.start
      service new_resource.servicename do
        action [:start]
        not_if { service_installed }
      end
    end

    new_resource.updated_by_last_action(!service_installed)
  else
    log('NSSM service can only be installed on Windows platforms!') { level :warn }
  end
end

action :remove do
  if platform?('windows')
    service_installed = service_installed?(new_resource.servicename)

    batch "Remove service #{new_resource.servicename}" do
      code <<-EOH
        #{nssm_exe} remove "#{new_resource.servicename}" confirm
      EOH
      only_if { service_installed }
    end

    new_resource.updated_by_last_action(service_installed)
  else
    log('NSSM service can only be removed from Windows platforms!') { level :warn }
  end
end
