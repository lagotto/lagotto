class Api::BaseController < ActionController::Base
  # include base controller methods
  include Authenticable

  # include helper module for DOI resolution
  include Resolvable

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
    key, value = id_hash.first
    @work = Work.where(key => value).first

    render json: { error: "Work not found." }.to_json, status: :not_found if @work.nil?
  end

  private

  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user.try(:is_admin?)
  end
end
