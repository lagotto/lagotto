class HeartbeatService
  def self.mysql_up?
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

  def self.memcached_up?
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
