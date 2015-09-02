default['ruby']['deploy_user'] = "vagrant"
default['ruby']['deploy_group'] = "vagrant"
default['ruby']['rails_env'] = "development"
default['ruby']['merge_slashes_off'] = true
default['ruby']['api_only'] = false

default['ruby']['packages'] = %w{ curl git python-software-properties software-properties-common zlib1g-dev }
default['ruby']['packages'] += %w{ avahi-daemon libnss-mdns } if node['ruby']['rails_env'] != "production"

default["dotenv"] = "default"
default["application"] = "lagotto"

default['couch_db']['config']['httpd']['bind_address'] = "0.0.0.0" if node['ruby']['rails_env'] != "production"

default['nodejs']['repo'] = 'https://deb.nodesource.com/node_0.12'
default['nodejs']['npm_packages'] = [{ "name" => "phantomjs" },
                                     { "name" => "istanbul"},
                                     { "name" => "codeclimate-test-reporter" }]
