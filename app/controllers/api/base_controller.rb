class Api::BaseController < ActionController::Base
  # include base controller methods
  include Authenticable

  # include helper module for query caching
  include Cacheable

  # utility methods for DOI metadata
  include Bolognese::Utils
  include Bolognese::DoiUtils

  prepend_before_filter :authenticate_user_from_token!
  before_filter :default_format_json
  after_filter :cors_set_access_control_headers, :set_jsonp_format

  protected

  def is_admin_or_staff?
    current_user && current_user.is_admin_or_staff? ? 1 : 0
  end
end
