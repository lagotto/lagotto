set :rails_env, ENV['RAILS_ENV']

ENV['SERVERS'].split(",").each_with_index do |s, i|
  # only primary server has db and workers role
  r = i > 0 ? %w(web app) : %w(web app db workers)

  server s, user: ENV['DEPLOY_USER'], roles: r
end
