set :stage, :development
set :branch, 'develop'
set :deploy_user, 'vagrant'
set :rails_env, :development

set :bundle_without, nil
set :bundle_flags, nil

role :app, %w{33.33.33.44}
role :web, %w{33.33.33.44}
role :db,  %w{33.33.33.44}

set :ssh_options, {
  user: "vagrant",
  keys: %w(~/.vagrant.d/insecure_private_key),
  auth_methods: %w(publickey)
}