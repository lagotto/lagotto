require "timeout"

class Heartbeat
  attr_reader :string, :status

  def initialize
    if services_up?
      @string = "OK"
      @status = 200
    else
      @string = "failed"
      @status = 500
    end
  end

  def human_status(service)
    service ? "OK" : "failed"
  end

  def services_up?
    [memcached_up?, redis_up?, sidekiq_up?].all?
  end

  def memcached_up?
    host = ENV["MEMCACHE_SERVERS"] || ENV["HOSTNAME"]
    memcached_client = Dalli::Client.new("#{host}:11211")
    memcached_client.alive!
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
