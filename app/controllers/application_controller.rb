class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :miniprofiler

  respond_to :json, :html, :rss

  layout 'application'

  rescue_from ActiveRecord::RecordNotFound, CanCan::AccessDenied do |exception|
    respond_with do |format|
      format.html { redirect_to root_path, alert: "The page you are looking for doesn't exist." }
      format.json { render json: { error: "The page you are looking for doesn't exist." }.to_json, status: 404 }
      format.rss { render :show, status: 404, layout: false }
    end
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || user_path("me")
  end

  private

  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user && current_user.is_admin?
  end
end
