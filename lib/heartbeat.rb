require "net/smtp"

class Heartbeat < Sinatra::Base
  get "" do
    content_type :json

    { services: services,
      version: Lagotto::VERSION,
      status: status }.to_json
  end

  def status
    if mysql == "OK" && memcached == "OK" && redis == "OK" && sidekiq == "OK" && postfix == "OK"
      "OK"
    else
      "failed"
    end
  end

  def services
    { mysql: mysql,
      memcached: memcached,
      redis: redis,
      sidekiq: sidekiq,
      postfix: postfix }
  end

  def mysql
    Mysql2::Client.new(host: ENV["DB_HOST"],
                       port: ENV["DB_PORT"],
                       username: ENV["DB_USERNAME"],
                       password: ENV["DB_PASSWORD"])
    "OK"
  rescue
    "failed"
  end

  def redis
    redis_client = Redis.new
    redis_client.ping == "PONG" ? "OK" : "failed"
  rescue
    "failed"
  end

  def memcached
    host = ENV["MEMCACHE_SERVERS"] ||= ENV["HOSTNAME"]
    memcached_client = Dalli::Client.new("#{host}:11211")
    memcached_client.version.values.first.nil? ? "failed" : "OK"
  rescue
    "failed"
  end

  def sidekiq
    sidekiq_client = Sidekiq::ProcessSet.new
    sidekiq_client.size > 0 ? "OK" : "failed"
  rescue
    "failed"
  end

  def postfix
    Net::SMTP.start(ENV["MAIL_ADDRESS"], ENV["MAIL_PORT"])
    "OK"
  rescue
    "failed"
  end
end
