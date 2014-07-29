set :stage, :development
set :repo_url, 'file:///var/www/alm/shared/'
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "develop"
set :deploy_user, 'vagrant'
set :rails_env, :development

# install all gems into system
set :bundle_without, nil
set :bundle_binstubs, nil
set :bundle_path, nil
set :bundle_flags, '--system'

# precompile assets in development
set :assets_roles, [:web, :app]

server '33.33.33.44', roles: %w{web app db}

set :ssh_options, user: "vagrant", keys: %w(~/.vagrant.d/insecure_private_key), auth_methods: %w(publickey)

# Set number of delayed_job workers
set :delayed_job_args, "-n 3"
