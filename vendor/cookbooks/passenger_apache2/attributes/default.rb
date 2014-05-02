default[:passenger][:version]     = "4.0.21"
default[:passenger][:max_pool_size] = "6"
default[:passenger][:root_path]   = "/var/lib/gems/2.1.0/gems/passenger-#{passenger[:version]}"
default[:passenger][:module_path] = "#{passenger[:root_path]}/ext/apache2/mod_passenger.so"
default[:passenger][:apache_mpm]  = 'prefork'
