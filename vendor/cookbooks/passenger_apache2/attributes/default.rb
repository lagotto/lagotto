default['passenger']['install_method'] = 'source'

default['passenger']['version']     = '3.0.19'
default['passenger']['apache_mpm']  = nil
default['passenger']['root_path']   = "#{languages['ruby']['gems_dir']}/gems/passenger-#{passenger['version']}"
default['passenger']['module_path'] = "#{passenger['root_path']}/ext/apache2/mod_passenger.so"
default['passenger']['max_pool_size'] = 6
default['passenger']['manage_module_conf'] = true
default['passenger']['package']['name'] = nil
default['passenger']['package']['version'] = node['passenger']['version']
