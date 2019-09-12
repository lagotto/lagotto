workers Integer(ENV['PUMA_WORKERS'] || 1)
threads_count = Integer(ENV['PUMA_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup DefaultRackup

port Integer(ENV['APP_PORT'] || 9292)

environment ENV['RAILS_ENV'] || 'development'

stdout_redirect(stdout = '/dev/stdout', stderr = '/dev/stderr', append = true)
