class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :miniprofiler

  layout 'application'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def default_url_options
    { host: CONFIG[:public_server] }
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || user_path("me")
  end

  private

  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user.try(:is_admin?)
  end
end
