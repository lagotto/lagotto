class ApplicationController < ActionController::Base
  # include base controller methods
  include Authenticable

  # include helper module for DOI resolution
  include Resolvable

  # include helper module for query caching
  include Cacheable

  protect_from_forgery

  before_filter :miniprofiler

  layout 'application'

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || user_path("me")
  end

  private

  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user && current_user.is_admin?
  end
end
