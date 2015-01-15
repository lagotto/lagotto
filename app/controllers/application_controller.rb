class ApplicationController < ActionController::Base
  # include base controller methods
  include Authenticable

  # include helper module for DOI resolution
  include Resolvable

  protect_from_forgery

  before_filter :miniprofiler

  respond_to :json, :html, :rss, :xml

  layout 'application'

  rescue_from ActiveRecord::RecordNotFound, CanCan::AccessDenied do |exception|
    respond_with do |format|
      format.html do
        if /(jpe?g|png|gif)/i === request.path
          render text: "404 Not Found", status: 404
        else
          @alert = Alert.new(message: "The page you are looking for doesn't exist.", status: 404)
          render "alerts/show", status: 404
        end
      end
      format.json { render json: { error: "The page you are looking for doesn't exist." }.to_json, status: 404 }
      format.xml { render xml: { error: "The page you are looking for doesn't exist." }.to_xml, status: 404 }
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
