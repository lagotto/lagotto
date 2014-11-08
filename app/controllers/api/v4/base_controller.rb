class Api::V4::BaseController < ActionController::Base
  # include base controller methods
  include Authenticable

  respond_to :json, :js

  prepend_before_filter :disable_devise_trackable
  before_filter :default_format_json, :authenticate_user_via_basic_authentication!
  after_filter :set_jsonp_format
end
