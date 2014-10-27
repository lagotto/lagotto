set :rails_env, 'staging'

ENV['SERVERS'].split(",").each_with_index do |s, i|
  # only primary server has db and workers role
  r = i > 0 ? %w(web app) : %w(web app db workers)

  server s, user: ENV['USER'], roles: r
end
