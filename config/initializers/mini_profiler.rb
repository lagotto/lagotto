require 'rack-mini-profiler'

Rack::MiniProfilerRails.initialize!(Rails.application)

Rails.application.middleware.delete(Rack::MiniProfiler)
Rails.application.middleware.insert_after(Rack::Deflater, Rack::MiniProfiler)

uri = URI.parse(ENV["REDIS_URL"])
Rack::MiniProfiler.config.storage_options = { :host => uri.host, :port => uri.port }
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
