require "net/smtp"
require "timeout"

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
    HeartbeatService.mysql_up? ? "OK" : "failed"
  end

  def redis
    HeartbeatService.redis_up? ? "OK" : "failed"
  end

  def memcached
    HeartbeatService.memcached_up? ? "OK" : "failed"
  end

  def sidekiq
    HeartbeatService.sidekiq_up? ? "OK" : "failed"
  end

  def postfix
    HeartbeatService.postfix_up? ? "OK" : "failed"
  end
end
