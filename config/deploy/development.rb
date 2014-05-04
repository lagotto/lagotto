set :stage, :development
set :repo_url, 'file:///var/www/alm/shared/'
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "feature/ALM-612"
set :deploy_user, 'vagrant'
set :rails_env, :development

# install all gems into system
set :bundle_without, nil
set :bundle_binstubs, nil
set :bundle_path, nil
set :bundle_flags, '--system'

# precompile assets in development
set :assets_roles, [:web, :app]

role :app, %w{33.33.33.44}
role :web, %w{33.33.33.44}
role :db,  %w{33.33.33.44}

set :ssh_options, user: "vagrant", keys: %w(~/.vagrant.d/insecure_private_key), auth_methods: %w(publickey)

# Set number of delayed_job workers
set :delayed_job_args, "-n 3"
