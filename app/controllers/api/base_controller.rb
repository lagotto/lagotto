class Api::BaseController < ActionController::Base
  # include base controller methods
  include Authenticable

  # include helper module for DOI resolution
  include Resolvable

  # include helper module for query caching
  include Cacheable

  prepend_before_filter :disable_devise_trackable
  before_filter :miniprofiler,
                :default_format_json,
                :authenticate_user_from_token!,
                :cors_preflight_check
  after_filter :cors_set_access_control_headers, :set_jsonp_format

  protected

  def load_work
    # Load one work given query params
    id_hash = get_id_hash(params[:id])
    if id_hash.present?
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      @work = nil
    end
    fail ActiveRecord::RecordNotFound unless @work.present?
  end

  def is_admin_or_staff?
    current_user && current_user.is_admin_or_staff? ? 1 : 0
  end

  private

  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user.try(:is_admin?)
  end
end
