class HeartbeatController < ApplicationController
  # include base controller methods
  include Authenticable

  respond_to :json

  before_filter :default_format_json, :cors_preflight_check
  after_filter :cors_set_access_control_headers, :set_jsonp_format

  def show
    @status = Status.first
    fail ActiveRecord::RecordNotFound if @status.nil?

    @process = SidekiqProcess.new
  end
end
