set :rails_env, ENV['RAILS_ENV']

ENV['SERVERS'].split(",").each_with_index do |s, i|

  # define servers that don't run db and workers
  if ENV['APP_SERVERS'].to_s.split(",").include?(s)
    r = %w(web app)
  else
    r = %w(web app db workers)
  end

  server s, user: ENV['DEPLOY_USER'], roles: r
end
