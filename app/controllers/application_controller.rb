class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :miniprofiler

  layout 'application'

  rescue_from ActiveRecord::RecordNotFound, CanCan::AccessDenied do |exception|
    respond_with do |format|
      format.html { redirect_to root_path, alert: "The page you are looking for doesn't exist.", status: 404 }
      format.json { render json: { error: "The page you are looking for doesn't exist." }.to_json, status: 404 }
      format.rss { render :show, status: 404, layout: false }
    end
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
