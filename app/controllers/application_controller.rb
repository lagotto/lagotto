class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :miniprofiler

  layout 'application'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path
  end

  def default_url_options
    { host: CONFIG[:public_server] }
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || user_path("me")
  end

  # from https://github.com/spree/spree/blob/master/api/app/controllers/spree/api/base_controller.rb
  def set_jsonp_format
    if params[:callback] && request.get?
      self.response_body = "#{params[:callback]}(#{response.body})"
      headers["Content-Type"] = 'application/javascript'
    end
  end

  private

  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user.try(:is_admin?)
  end
end
