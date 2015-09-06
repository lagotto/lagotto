require "net/smtp"
require "timeout"

class Heartbeat < Sinatra::Base
  get "" do
    content_type :json

    { services: services,
      version: Lagotto::VERSION,
      status: human_status(services_up?) }.to_json
  end

  def services
    { mysql: human_status(mysql_up?),
      memcached: human_status(memcached_up?),
      redis: human_status(redis_up?),
      sidekiq: human_status(sidekiq_up?),
      postfix: human_status(postfix_up?) }
  end

  def human_status(service)
    service ? "OK" : "failed"
  end

  def services_up?
    [mysql_up?, memcached_up?, redis_up?, sidekiq_up?, postfix_up?].all?
  end

  def mysql_up?
    Mysql2::Client.new(
      host: ENV["DB_HOST"],
      port: ENV["DB_PORT"],
      username: ENV["DB_USERNAME"],
      password: ENV["DB_PASSWORD"]
    )
    true
  rescue
    false
  end

  def memcached_up?
    host = ENV["MEMCACHE_SERVERS"] || ENV["HOSTNAME"]
    memcached_client = Dalli::Client.new("#{host}:11211")
    memcached_client.alive!
    true
  rescue
    false
  end

  def postfix_up?
    Timeout::timeout(3) do
      Net::SMTP.start(ENV["MAIL_ADDRESS"], ENV["MAIL_PORT"])
    end
    true
  rescue
    false
  end

  def redis_up?
    redis_client = Redis.new
    redis_client.ping == "PONG"
  rescue
    false
  end

  def sidekiq_up?
    sidekiq_client = Sidekiq::ProcessSet.new
    sidekiq_client.size > 0
  rescue
    false
  end
end
