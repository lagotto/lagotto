default[:passenger][:version]     = "3.0.7"
default[:passenger][:max_pool_size] = "6"
default[:passenger][:root_path]   = "#{languages[:ruby][:gems_dir]}@global/gems/passenger-#{passenger[:version]}"
default[:passenger][:module_path] = "#{passenger[:root_path]}/ext/apache2/mod_passenger.so"
