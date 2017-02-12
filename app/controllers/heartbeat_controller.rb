class HeartbeatController < ApplicationController
  def index
    heartbeat = Heartbeat.new
    render plain: heartbeat.string, status: heartbeat.status, content_type: "text/html"
  end
end
