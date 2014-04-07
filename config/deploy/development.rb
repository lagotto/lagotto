set :stage, :development
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "develop"
set :deploy_user, 'vagrant'
set :rails_env, :development

# install all gems into system
set :bundle_without, nil
set :bundle_binstubs, nil
set :bundle_path, nil
set :bundle_flags, '--system'

# don't precompile assets
set :assets_roles, []

role :app, %w{33.33.33.55}
role :web, %w{33.33.33.55}
role :db,  %w{33.33.33.55}

set :ssh_options, {
  user: "vagrant",
  keys: %w(~/.vagrant.d/insecure_private_key),
  auth_methods: %w(publickey)
}

# Set number of delayed_job workers
set :delayed_job_args, "-n 3"