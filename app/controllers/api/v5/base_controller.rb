class Api::V5::BaseController < ActionController::Base
  # include base controller methods
  include Authenticable

  respond_to :json

  before_filter :miniprofiler,
                :default_format_json,
                :authenticate_user_from_token!,
                :cors_preflight_check
  after_filter :cors_set_access_control_headers, :set_jsonp_format

  private

  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user.try(:is_admin?)
  end
end
